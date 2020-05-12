require 'sqlite3'
require 'active_record'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'ibge.db')

class IbgeDB
  class Estado < ActiveRecord::Base
    self.table_name = 'estados'
  end

  class Cidade < ActiveRecord::Base
    self.table_name = 'cidades'
  end
end