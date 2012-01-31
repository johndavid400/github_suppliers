require 'spree_core'
require 'spree_suppliers/engine'

module SpreeSuppliers
  class Engine < Rails::Engine
    config.autoload_paths += %W(#{config.root}/lib)
    def self.activate
      Ability.register_ability(AbilityDecorator)

      LineItem.class_eval do
        has_many :invoice_items
      end

      Image.class_eval do
        belongs_to :supplier
      end

      Order.class_eval do
        has_many :supplier_invoices
        def generate_invoices(order)
          @order = order
          @order_products = @order.line_items
          @suppliers = @order_products.collect{|item| item.product.supplier_id}.uniq
          @invoices = @suppliers.count

          for i in 0..@invoices - 1
            @supplier_products = @order_products.select{|x| x.product.supplier_id == @suppliers[i]}
            @product_count = @supplier_products.count
            invoice = SupplierInvoice.create(:order_id => @order.id, :supplier_id => @suppliers[i], :item_count => @product_count)

            @supplier_products.each do |item|
              invoice.items.create(:product_id => item.product.id, :quantity => item.quantity, :line_item_id => item.id)
            end

            item_total = "0.00".to_d
            invoice.items.each do |i|
              item_total = (i.line_item.variant.price * i.quantity) + item_total
            end
            invoice.update_attributes(:invoice_total => item_total)
            @invoice = invoice
            #SupplierMailer.invoice_email(@invoice).deliver
          end
        end
        def finalize!
          update_attribute(:completed_at, Time.now)
          self.out_of_stock_items = InventoryUnit.assign_opening_inventory(self)
          # lock any optional adjustments (coupon promotions, etc.)
          adjustments.optional.each { |adjustment| adjustment.update_attribute("locked", true) }
          # generate the invoices for each supplier
          generate_invoices(self)
          #OrderMailer.confirm_email(self).deliver

          self.state_events.create({
            :previous_state => "cart",
            :next_state     => "complete",
            :name           => "order" ,
            :user_id        => (User.respond_to?(:current) && User.current.try(:id)) || self.user_id
          })
        end
      end

      Taxon.class_eval do
        has_and_belongs_to_many :suppliers
      end

      User.class_eval do
        belongs_to :supplier
      end

    end
    config.to_prepare &method(:activate).to_proc
  end
end

