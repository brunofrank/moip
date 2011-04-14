module MoipHelper
  MOIP_FORM_VIEW = File.expand_path(File.dirname(__FILE__) + "/views/_form.html.erb")
  
  def moip_form(order, options={})
    options = {
      :submit => "Pagar com Moip"
    }.merge(options)

    render :file => MOIP_FORM_VIEW, :locals => {:options => options, :order => order}
  end
end
