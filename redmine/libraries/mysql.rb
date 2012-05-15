module Mysql
  def database_names
    `echo 'show databases' | mysql -uroot --skip_column_names`.chomp.split($/)
  end

  def has_database?(name)
    database_names.include? name
  end
end
