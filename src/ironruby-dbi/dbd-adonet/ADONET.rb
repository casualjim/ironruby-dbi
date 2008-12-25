module DBI
  module DBD
    module ADO
      
      VERSION          = "0.1"
      USED_DBD_VERSION = "0.1"
      FACTORIES        = {
                            :odbc => "OdbcFactory",
                            :oledb => "OleDbFactory",
                            :oracle => "OracleClientFactory",
                            :mssql => "SqlClientFactory",
                            :sqlce => "SqlCeProviderFactory",
                            :mysql => "MySqlClientFactory",
                            :sqlite => "SQLiteFactory"
                         }
      
      class Driver < DBI::BaseDriver
        
        def initialize
          super(USED_DBD_VERSION)
        end
        
        def connect(driver_url, user, auth, attr)
          provider, connection = parse_connection_string(driver_url)
          dbd_driver = DbdDriver.new(FACTORIES[provider.to_sym])
          
          return Database.new(dbd_driver.connect(connection))
        rescue RuntimeError => err
          raise DBI::DatabaseError.new(err.message)
        end
        
        private
        
          def parse_connection_string(connection_string)
            if connection_string =~ /^([^:]+)(:(.*))$/ 
              [$1, $3]
            else
              raise InterfaceError, "Invalid provider name"
            end
          end
        
      end
      
      class Database < DBI::BaseDatabase
        
        def initialize(dbd_db)
          super()
          @dbd_db = dbd_db
        end
        
        def disconnect
          @dbd_db.disconnect
        rescue RuntimeError => err
          raise DBI::DatabaseError.new(err.message)
        end
        
        def prepare(statement)
          # TODO: create Command instead?
          Statement.new(@dbd_db.prepare)
        end
        
        def ping
          @dbd_db.ping
        rescue RuntimeError => err
          raise DBI::DatabaseError.new(err.message)
        end 
        
        def commit
          @dbd_db.commit
        rescue RuntimeError => err
          raise DBI::DatabaseError.new(err.message)
        end
        
        def rollback
          # TODO: raise error if AutoCommit on => better in DBI?
          @dbd_db.rollback
        rescue RuntimeError => err
          raise DBI::DatabaseError.new(err.message)
        end       
        
      end # class Database
      
      class Statement < DBI::BaseStatement
        
        def initialize(dbd_statement)
          @dbd_statement = dbd_statement
        end 
        
        def bind_param(name, value, attribs)
          @dbd_statement.bind_param(name, value, attribs)
        end 
        
        def execute
          @dbd_statement.execute
        rescue RuntimeError => err
          raise DBI::DatabaseError.new(err.message)
        end 
        
        def fetch
          @dbd_statement.fetch
        rescue RuntimeError => err
          raise DBI::DatabaseError.new(err.message)
        end 
        
        def finish
          @dbd_statement.finish
        rescue RuntimeError => err
          raise DBI::DatabaseError.new(err.message)
        end 
        
        def column_info
          @dbd_statement.column_info
        rescue RuntimeError => err
          raise DBI::DatabaseError.new(err.message)
        end 
        
        def rows
          @dbd_statement.rows
        end 
      end
      
    end
  end
end