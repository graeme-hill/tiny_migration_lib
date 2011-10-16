require 'rubygems' if RUBY_VERSION < '1.9'
require 'sql_wrangler'

class TinyMigrator
  
  def self.get_database_version(conn)
    if migration_history_initialized?(conn)
      query = conn.query('select max(version) as version from MigrationHistory')
      return Integer(query.execute()[0]['version'])
    else
      return nil
    end
  end
  
  def self.run_migrations(conn, migrations)
    
    init_migration_history(conn) if not migration_history_initialized?(conn)
    
    version = get_database_version(conn)
    migrations.sort_by { |m| m.version }.each do |migration|
      if migration.version > version
        migration.run(conn)
      end
    end
  end
  
  private
  
  def self.migration_history_initialized?(conn)
    query = conn.query("
      select count(*) as c 
      from sqlite_master 
      where type='table' and name='MigrationHistory'")
    return Integer(query.execute()[0]['c']) > 0
  end
  
  def self.init_migration_history(conn)
    conn.command("create table MigrationHistory (version int, dateMigrated text)")
  end
  
end

class Migration
  
  def version
    raise NotImplementedError.new('You need to implement version method')
  end
  
  def sql
    raise NotImplementedError.new('You need to implement sql method')
  end
  
  def run(conn)
    # execute the actual migration
    conn.command(sql)
    # record the new version in migration history
    conn.command("
      insert into MigrationHistory (version, dateMigrated) 
      values (#{self.version}, '#{Time.now}')")
  end
  
end
  
  
