require 'rest-client'
require 'json'

class IbgeApi
  def self.get_states_from_brazil
    response = RestClient.get 'https://servicodados.ibge.gov.br/api/v1/localidades/estados'
    JSON.parse(response.body, symbolize_names: true)
  end

  def self.get_name_frequency(names)
    query_string = names.gsub(/\s+/, '').gsub(',', '%7C')
    response = RestClient.get "https://servicodados.ibge.gov.br/api/v2/censos/nomes/#{query_string}"
    JSON.parse(response.body, symbolize_names: true)
  end

  def self.get_cities_from_brazil
    response = RestClient.get 'https://servicodados.ibge.gov.br/api/v1/localidades/municipios'
    JSON.parse(response.body, symbolize_names: true)
  end

  def self.get_most_frequent_names(location_id: '', gender: '')
    query_string = ''
    
    if !location_id.to_s.empty?
      query_string = "localidade=#{location_id}"
      if !gender.empty?
        query_string = query_string + "&sexo=#{gender}"
      end
    elsif !gender.empty?
      query_string = "sexo=#{gender}"
    end
  
    response = RestClient.get "https://servicodados.ibge.gov.br/api/v2/censos/nomes/ranking?#{query_string}"
    JSON.parse(response.body, symbolize_names: true)[0]
  end

  def self.convert_initials_state_to_id(initials)
    states = Api.get_states_from_brazil
    state = states.select {|state| state[:sigla].eql? initials.upcase}
    state[0][:id]
  end
end
