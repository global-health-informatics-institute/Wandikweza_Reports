module ApplicationHelper
    def facility_name
        YAML.load_file("#{Rails.root}/config/application.yml")['facility_name']
    end
    
    def current_user
        @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end

    def local_currency(amount)
        return number_to_currency(amount, unit: "MWK ")
    end
end
