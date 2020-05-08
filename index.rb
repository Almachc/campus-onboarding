require 'json'
require_relative 'api'

def choose_a_state
  states = Api.get_states_from_brazil
  puts ''
  puts 'ESTADOS DO BRASIL:'
  puts ''
  states.each {|state| puts "Estado: #{state[:nome]} | Sigla: #{state[:sigla]}"}
  puts ''
  print 'Digite a sigla do estado desejado: '
  gets().chomp
end

def generate_rankings(state_id)
  ranking_geral = Api.get_ranking_of_names_by(location_id: state_id)
  ranking_masc = Api.get_ranking_of_names_by(location_id: state_id, gender: 'M')
  ranking_fem = Api.get_ranking_of_names_by(location_id: state_id, gender: 'F')

  puts ''
  puts 'Ranking Geral'
  ranking_geral[:res].each {|item| puts "#{item[:ranking]} - #{item[:nome]}"}
  puts ''
  puts 'Ranking Masculino'
  ranking_masc[:res].each {|item| puts "#{item[:ranking]} - #{item[:nome]}"}
  puts ''
  puts 'Ranking Feminino'
  ranking_fem[:res].each {|item| puts "#{item[:ranking]} - #{item[:nome]}"}
  puts ''
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
opcao = menu()

while opcao != 4
  if opcao == 1
    initials = choose_a_state
    state_id = Api.convert_initials_state_to_id(initials)
    generate_rankings(state_id)
  elsif opcao == 2

  elsif opcao == 3

  else
    puts 'Opção inválida'
  end

  menu()
end
