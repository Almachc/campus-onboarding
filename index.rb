require 'json'
require_relative 'api'
require 'terminal-table'

def choose_names
  print 'Digite um ou mais nomes, separados por vírgula, a serem pesquisados: '
  gets().chomp
end

def choose_a_city
  print 'Digite corretamente o nome da cidade desejada: '
  city_name = gets().chomp
  Api.convert_name_city_to_id(city_name)
end

def choose_a_state
  states = Api.get_states_from_brazil
  rows = Array.new(states.length) {[]}
  states.each_with_index {|state, index| 
    rows[index] << state[:nome]
    rows[index] << state[:sigla]
  }
  puts Terminal::Table.new :title => 'Estados', :headings => ['Nome', 'Sigla'], :rows => rows
  print 'Digite a sigla correspondente ao estado desejado: '
  gets().chomp
end

def generate_name_frequency_table(names)
  name_frequency = Api.get_name_frequency(names)

  heading = ['Década']
  rows = Array.new(name_frequency[0][:res].length) {[]}

  name_frequency.each_with_index {|item1, index1|
    heading << item1[:nome]
    item1[:res].each_with_index {|item2, index2|
      if index1 == 0
        rows[index2] << item2[:periodo].delete('[')
      end
      rows[index2] << item2[:frequencia]
    }
  }

  puts Terminal::Table.new :headings => heading, :rows => rows
end

def generate_rankings(locality_id)
  ranking_geral = Api.get_ranking_of_names_by(location_id: locality_id)
  ranking_masc = Api.get_ranking_of_names_by(location_id: locality_id, gender: 'M')
  ranking_fem = Api.get_ranking_of_names_by(location_id: locality_id, gender: 'F')

  heading = ['Ranking Geral', 'Ranking Masculino', 'Ranking Feminino']
  rows = Array.new(ranking_geral[:res].length) {[]}

  ranking_geral[:res].each_with_index {|item, index| 
    rows[index] << "#{item[:ranking]} - #{item[:nome]}"
  }
 
  ranking_masc[:res].each_with_index {|item, index| 
    rows[index] << "#{item[:ranking]} - #{item[:nome]}"
  }
  
  ranking_fem[:res].each_with_index {|item, index| 
    rows[index] << "#{item[:ranking]} - #{item[:nome]}"
  }
  
  puts Terminal::Table.new :headings => heading, :rows => rows
end

def welcome()
  puts 'BEM VINDO AO SISTEMA DE NOMES DO IBGE!!!'
  puts ''
end

def menu
  puts 'MENU:'
  puts ''
  puts '[1] Ranking dos nomes mais comuns em uma determinada Unidade Federativa (UF)'
  puts '[2] Ranking dos nomes mais comuns em uma determinada cidade'
  puts '[3] Frequência do uso de um nome ao longo dos anos'
  puts '[4] Sair'
  puts ''
  print 'Digite a opção desejada: '
  gets().to_i()
end

#Interface
welcome()
option = menu()

while option != 4
  if option == 1
    initials = choose_a_state
    state_id = Api.convert_initials_state_to_id(initials)
    generate_rankings(state_id)
  elsif option == 2
    city_id = choose_a_city
    generate_rankings(city_id)
  elsif option == 3
    names = choose_names
    generate_name_frequency_table(names)
  else
    puts 'Opção inválida'
  end

  option = menu()
end
