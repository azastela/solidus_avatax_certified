# frozen_string_literal: true

module SolidusAvataxCertified
  class Seeder
    class << self
      def seed!
        create_use_codes
        create_tax
        add_tax_category_to_shipping_methods
        add_tax_category_to_products
        populate_default_stock_location

        puts "***** SOLIDUS AVATAX CERTIFIED *****"
        puts ""
        puts "Please remember to:"
        puts "- Add tax category to all shipping methods that need to be taxed."
        puts "- Don't assign anything default tax."
        puts "- Assign proper Tax Category to each product"
        puts "- Fill in Stock Location Address."
        puts "- Fill Origin Address in Avatax Settings."
        puts ""
        puts "***** SOLIDUS AVATAX CERTIFIED *****"
      end

      def seed_use_codes!
        create_use_codes
        puts "***** SOLIDUS AVATAX CERTIFIED: Use Codes Seeded"
      end

      def create_tax
        default_tax_category = ::Spree::TaxCategory.find_by(name: 'Default')
        default_tax_rate = ::Spree::TaxRate.find_by(name: 'North America')

        default_tax_category&.destroy
        default_tax_rate&.destroy

        clothing = ::Spree::TaxCategory.find_or_create_by(name: 'Clothing')
        clothing.update(tax_code: 'P0000000')
        tax_zone = ::Spree::Zone.find_or_create_by(name: 'North America')
        tax_calculator = ::Spree::Calculator::AvalaraTransaction.create!
        sales_tax = ::Spree::TaxRate.find_or_create_by(name: 'Tax') do |tax_rate|
          # default values for the create
          tax_rate.amount = BigDecimal('0')
          tax_rate.calculator = tax_calculator
        end

        sales_tax.tax_categories << clothing

        sales_tax.update!(name: 'Tax', amount: BigDecimal('0'), zone: tax_zone, show_rate_in_label: false, calculator: tax_calculator)

        shipping = ::Spree::TaxCategory.find_or_create_by(name: 'Shipping', tax_code: 'FR000000')
        shipping_tax = ::Spree::TaxRate.find_or_create_by(name: 'Shipping Tax') do |shipping_tax|
          shipping_tax.amount = BigDecimal('0')
          shipping_tax.zone = tax_zone
          shipping_tax.show_rate_in_label = false
        end

        shipping_tax.tax_categories << shipping

        shipping_tax.update!(amount: BigDecimal('0'), zone: ::Spree::Zone.find_by_name('North America'), show_rate_in_label: false, calculator: ::Spree::Calculator::AvalaraTransaction.create!)
      end

      def add_tax_category_to_shipping_methods
        ::Spree::ShippingMethod.update_all(tax_category_id: ::Spree::TaxCategory.find_by(name: 'Shipping').id)
      end

      def add_tax_category_to_products
        ::Spree::Product.update_all(tax_category_id: ::Spree::TaxCategory.find_by(name: 'Clothing').id)
      end

      def populate_default_stock_location
        default = ::Spree::StockLocation.find_or_create_by(name: 'default')

        return unless default.zipcode.nil? || default.address1.nil?

        state = ::Spree::State.find_by(name: 'Alabama')

        address = {
          address1: '915 S Jackson St',
          city: 'Montgomery',
          state: state,
          country: state.country,
          zipcode: '36104',
          default: true,
          name: 'default',
          backorderable_default: true
        }

        default.update(address)
      end

      def create_use_codes
        unless ::Spree::AvalaraEntityUseCode.count >= 16
          use_codes.each do |key, value|
            ::Spree::AvalaraEntityUseCode.find_or_create_by(use_code: key, use_code_description: value)
          end
        end
      end

      def use_codes
        {
          "A" => "Federal government",
          "B" => "State government",
          "C" => "Tribe/Status Indian/Indian Band",
          "D" => "Foreign diplomat",
          "E" => "Charitable or benevolent organization",
          "F" => "Religious or educational organization",
          "G" => "Resale",
          "H" => "Commercial agricultural production",
          "I" => "Industrial production/manufacturer",
          "J" => "Direct pay permit",
          "K" => "Direct mail",
          "L" => "Other",
          "N" => "Local government",
          "P" => "Commercial aquaculture (Canada only)",
          "Q" => "Commercial fishery (Canada only)",
          "R" => "Non-resident (Canada only)"
        }
      end
    end
  end
end
