require 'carmen-rails'

module EffectiveAddressesHelper
  def effective_address_fields(form, method = 'billing', options = {})
    method = (method.to_s.include?('_address') ? method.to_s : "#{method}_address")

    opts = {:f => form, :method => method}.merge(options)

    if form.class.name == 'SimpleForm::FormBuilder'
      render :partial => 'effective/addresses/address_fields_simple_form', :locals => opts
    elsif form.class.name == 'Formtastic::FormBuilder'
      render :partial => 'effective/addresses/address_fields_formtastic', :locals => opts
    else
      raise 'Unsupported FormBuilder.  You must use formtastic or simpleform. Sorry.'
    end
  end

  def region_options_for_simple_form_select(regions = nil)
    if regions.present?
      countries = regions
    elsif EffectiveAddresses.country_codes == :all
      countries = Carmen::Country.all
    else
      countries = Carmen::Country.all.select { |c| (EffectiveAddresses.country_codes || []).include?(c.code) }
    end

    collection = countries.map { |c| [c.name, c.code] }.sort! { |a, b| a.first <=> b.first }

    if regions.blank? && EffectiveAddresses.country_codes_priority.present?
      collection.insert(0, ['---------------------', '', :disabled])

      EffectiveAddresses.country_codes_priority.reverse.each do |code|
        if (country = countries.coded(code))
          collection.insert(0, [country.name, country.code])
        end
      end
    end

    collection
  end

end

