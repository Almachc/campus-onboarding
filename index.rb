require_relative 'lib/ibgeApi'
require_relative 'lib/ibgeDB'
require 'terminal-table'
require 'csv'

def total_population?(location_id:)
  populacao = nil
  CSV.foreach("assets/populacao_2019.csv", headers: true) do |row|
    if row["Cód."].to_i == location_id
      populacao = row["População Residente - 2019"] 
      break
    end
  end
  populacao.to_i
end

def choose_names
  print 'Digite um ou mais nomes, separados por vírgula, a serem pesquisados: '
  gets().chomp
end

def choose_city
  print 'Digite corretamente o nome da cidade desejada: '
  city_name = gets().chomp
  IbgeDB::Cidade.find_by_sql("SELECT id FROM cidades WHERE nome = \"#{city_name}\"")[0][:id]
end

def choose_state
  states = IbgeDB::Estado.all
  rows = Array.new(states.length) {[]}
  states.each_with_index {|state, index| 
    rows[index] << state[:nome]
    rows[index] << state[:sigla]
  }
  puts Terminal::Table.new :title => 'Estados', :headings => ['Nome', 'Sigla'], :rows => rows
  print 'Digite a sigla correspondente ao estado desejado: '
  state_initials = gets().chomp.upcase
  IbgeDB::Estado.find_by_sql("SELECT id FROM estados WHERE sigla = \"#{state_initials}\"")[0][:id]
end

def generate_name_frequency_list(names)
  test_record = IbgeApi.get_name_frequency('Maria')[0][:res]
  valid_decades = test_record.map {|item|
    item[:periodo]
  }

  heading = ['Década']
  rows = valid_decades.map {|item, index|
    [item.delete('[')]
  }

  IbgeApi.get_name_frequency(names).each_with_index {|itemName, indexName|
    heading << itemName[:nome]
    valid_decades.each_with_index {|decade, indexVD|
      frequency = '--'
      itemName[:res].each_with_index {|itemDecade, indexDecade|
        frequency = itemDecade[:frequencia] if itemDecade[:periodo].eql? decade
      }
      rows[indexVD] << frequency
    }
  }

  puts Terminal::Table.new :headings => heading, :rows => rows
end

def mount_tables(rankings)
  ranking_tables = rankings.map {|ranking|
    heading = ['Posição', 'Nome', 'Frequência', 'Porcentagem']
    rows = Array.new(ranking[:data][:res].length) {[]}
  
    amount = total_population?(location_id: ranking[:data][:localidade].to_i)
  
    ranking[:data][:res].each_with_index {|item, index| 
      porcentagem = (item[:frequencia] * 100) / amount.to_f
      rows[index] << item[:ranking]
      rows[index] << item[:nome]
      rows[index] << item[:frequencia]
      rows[index] << "#{porcentagem.round(2)}%"
    }
   
    Terminal::Table.new :title => ranking[:title], :headings => heading, :rows => rows
  }
  
  puts Terminal::Table.new :rows => [ranking_tables], :style => {:border_x => '', :border_y => '',
                                                                 :border_top => false,
                                                                 :border_bottom => false}
end

def generate_name_popularity_ranking(location_id: '')
  all = IbgeApi.get_most_frequent_names(location_id: location_id)
  masc = IbgeApi.get_most_frequent_names(location_id: location_id, gender: "M")
  fem = IbgeApi.get_most_frequent_names(location_id: location_id, gender: "F")

  mount_tables([{data: all, title: 'Ranking Geral'}, {data: masc, title: 'Ranking Masculino'},
                {data: fem, title: 'Ranking Feminino'}])
end

def menu
  puts ''
  puts 'MENU:'
  puts '[1] Ranking dos nomes mais comuns em uma determinada Unidade Federativa (UF)'
  puts '[2] Ranking dos nomes mais comuns em uma determinada cidade'
  puts '[3] Frequência do uso de um nome ao longo dos anos'
  puts '[4] Sair'
  puts ''
  print 'Digite a opção desejada: '
  gets().to_i()
end

def welcome
  puts 'BEM VINDO AO SISTEMA DE NOMES DO IBGE!!!'
end

def startApplication
  welcome
  option = menu

  while option != 4
    if option == 1
      state_id = choose_state
      generate_name_popularity_ranking(location_id: state_id)
    elsif option == 2
      city_id = choose_city
      generate_name_popularity_ranking(location_id: city_id)
    elsif option == 3
      names = choose_names
      generate_name_frequency_list(names)
    else
      puts 'Opção inválida'
    end

    option = menu()
  end
end

startApplication
