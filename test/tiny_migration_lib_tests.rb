require 'rubygems' if RUBY_VERSION < '1.9'
require 'fas_test'
require './lib/tiny_migration_lib'

class MigrationOne < Migration
  def version
    return 1
  end
  def sql
    "create table tableOne (id int, name text)"
  end
end

class MigrationTwo < Migration
  def version
    return 2
  end
  def sql
    "create table tableTwo (id int, otherId int)"
  end
end
  
class TinyMigrationLibTests < FasTest::TestClass
  
  def test_setup
    @conn = SqlWrangler::SqLiteConnection.new ":memory:"
  end

  def test_teardown
    @conn.close
  end

  def test__get_database_version__after_migration
    TinyMigrator.run_migrations(@conn, [MigrationOne.new, MigrationTwo.new])
    assert_equal(2, TinyMigrator.get_database_version(@conn))
  end
  
  def test__get_database_version__before_any_migrations
    v = TinyMigrator.get_database_version(@conn)
    assert_equal(nil, v, "version should be null because migration history is not initialized")
  end
  
  def test__run_migrations__executes_correct_migrations
    TinyMigrator.run_migrations(@conn, [MigrationOne.new, MigrationTwo.new])
    query = @conn.query("
      select count(*) as c 
      from sqlite_master 
      where type='table' and (name='tableOne' or name='tableTwo')")
    assert_equal(2, query.execute()[0]['c'])
  end
  
  def test__run_migrations__works_incrementally
    TinyMigrator.run_migrations(@conn, [MigrationOne.new])
    query = @conn.query("
      select count(*) as c 
      from sqlite_master 
      where type='table' and (name='tableOne')")
    assert_equal(1, query.execute()[0]['c'])
    assert_equal(1, TinyMigrator.get_database_version(@conn))
    
    TinyMigrator.run_migrations(@conn, [MigrationOne.new, MigrationTwo.new])
    query = @conn.query("
      select count(*) as c 
      from sqlite_master 
      where type='table' and (name='tableOne' or name='tableTwo')")
    assert_equal(2, query.execute()[0]['c'])
    assert_equal(2, TinyMigrator.get_database_version(@conn))
  end
  
end