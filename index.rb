require_relative 'ibgeApi'
require_relative 'ibgeDB'
require 'terminal-table'
require 'csv'

def choose_names
  print 'Digite um ou mais nomes, separados por vírgula, a serem pesquisados: '
  gets().chomp
end

def choose_a_city
  print 'Digite corretamente o nome da cidade desejada: '
  city_name = gets().chomp
end

def choose_a_state
  states = IbgeDB::Estado.all
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
  name_frequency = IbgeApi.get_name_frequency(names)

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

def generate_ranking(location_id: '', gender: '')
  title = 'Ranking Geral'
  title = gender == 'M' ? 'Ranking Masculino' : 'Ranking Feminino' if !gender.empty?
  
  ranking = IbgeApi.get_ranking_of_names_by(location_id: location_id, gender: gender)

  heading = ['Pos', 'Nome', 'Frequência', 'Porcentagem']
  rows = Array.new(ranking[:res].length) {[]}

  populacao = teste(location_id: location_id)

  ranking[:res].each_with_index {|item, index| 
    porcentagem = (item[:frequencia] * 100) / populacao.to_f
    rows[index] << item[:ranking]
    rows[index] << item[:nome]
    rows[index] << item[:frequencia]
    rows[index] << "#{porcentagem.round(2)}%"
  }
 
  Terminal::Table.new :title => title, :headings => heading, :rows => rows
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

def welcome
  puts 'BEM VINDO AO SISTEMA DE NOMES DO IBGE!!!'
end

def teste(location_id:)
  populacao = nil
  CSV.foreach("assets/populacao_2019.csv", headers: true) do |row|
    if row["Cód."].to_i == location_id
      populacao = row["População Residente - 2019"] 
      break
    end
  end
  populacao.to_i
end

def startApplication
  welcome
  option = menu

  while option != 4
    if option == 1
      state_initials = choose_a_state
      result = IbgeDB::Estado.find_by_sql("SELECT id FROM estados WHERE sigla = \"#{state_initials.upcase}\"")
      geral = generate_ranking(location_id: result[0][:id])
      masc = generate_ranking(location_id: result[0][:id], gender: "M")
      fem = generate_ranking(location_id: result[0][:id], gender: "F")
      puts Terminal::Table.new :rows => [[geral, masc, fem]]
    elsif option == 2
      city_name = choose_a_city
      result = IbgeDB::Cidade.find_by_sql("SELECT id FROM cidades WHERE nome = \"#{city_name}\"")
      generate_rankings(location_id: result[0][:id])
    elsif option == 3
      names = choose_names
      generate_name_frequency_table(names)
    else
      puts 'Opção inválida'
    end

    option = menu()
  end
end

startApplication
