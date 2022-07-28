
use sd;

drop table if exists sdtest;
create table sdtest (
  id    bigint auto_increment not null,
  val   bigint not null,
  constraint id_key primary key (id),
  index val_key (val)
);

drop procedure if exists load_sdtest;

delimiter #
create procedure load_sdtest()
begin

declare v_max int unsigned default 5000000;
declare v_counter int unsigned default 0;

  truncate table sdtest;
  start transaction;
  while v_counter < v_max do
    insert into sdtest (val) values (floor(rand() * 100000000));
    set v_counter = v_counter + 1;
  end while;
  commit;
end #

delimiter ;

call load_sdtest ();

analyze table sdtest;
