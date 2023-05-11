package crud::Controller::ActorController;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use strict;
use warnings;
use DBI;

# Connect to database postgres
sub connect_db_pg {
  my $driver    = "Pg"; 
  my $dsn       = "DBI:Pg:dbname = learning-perl; host = localhost; port = 5432";
  my $database  = "learning-perl";
  my $user      = "postgres";
  my $password  = "123456";
  my $dbh       = DBI->connect($dsn, $user, $password, { RaiseError => 1 }) or die $DBI::errstr;
  print "Connect database successfully\n";
  return $dbh;
}
# Action showData
sub show {
  my $self  = shift;
  my $dbh   = connect_db_pg();
  my $sth   = $dbh->prepare(qq(SELECT * FROM actor ORDER BY actor_id;));
  # Show error if false 
  my $rv    = $sth->execute() or die $DBI::errstr;
  # show item put out
  ($rv < 0) ? print $DBI::errstr : print "Operation done successfully\n"; 
  # array of data
  my @rows;
  while (my $row = $sth->fetchrow_hashref) {
    push @rows, $row;
  }
  $sth->finish();
  $dbh->disconnect();
  $self->render(
    rows      => \@rows,
    template  => "admin/list"
  );
  return;
}
# Action formAdd
sub fromAdd {
  my $self  = shift;
  #Invalid error
  my $error = $self->flash('error');
  $self->render(
    template  => 'admin/add',
    error     => $error
  );
}
# Action Add
sub add {
  my $self        = shift;
  # Get value from form
  my $first_name  = $self->param('first_name');
  my $last_name   = $self->param('last_name');
  # Check valid first_name, last_name
  my $error;
  unless ($first_name =~ /^[A-Za-z\s]+$/ && $last_name =~ /^[A-Za-z\s]+$/) {
    $error = 'Thông tin nhập không hợp lệ vui lòng nhập lại';
  }
  # If error, show Notification and redirect to form add
  if ($error) {
    $self->flash(error => $error);
    return $self->redirect_to('/form-add');
  } else {
    # use function connect database 
    my $dbh = connect_db_pg();
    my $sth = $dbh->prepare(qq(INSERT INTO actor (first_name, last_name, last_update) VALUES ('$first_name', '$last_name', NOW())));
    my $rv  = $sth->execute() or die $DBI::errstr;
    ($rv < 0) ? print $DBI::errstr : print "Operation done successfully\n";
    $sth->finish();
    $dbh->disconnect();
    $self->flash(success => 'Thêm mới actor thành công');
    return $self->redirect_to('/');
  }
}
# Action formEdit
sub formUpdate {
  my $self  = shift;
  my $dbh   = connect_db_pg();
  my $id    = $self->stash('id');
  my $sth   = $dbh->prepare(qq(SELECT * FROM actor WHERE actor_id = $id LIMIT 1));
  my $rv    = $sth->execute() or die $DBI::errstr;
  my @rows;
  while (my $row = $sth->fetchrow_hashref) {
    push @rows, $row;
  }
  $self->render(
    rows      => \@rows,
    template  => 'admin/update'
  );
}
# Action Edit
sub update {
  my $self  = shift;
  my $dbh   = connect_db_pg();
  my $id    = $self->stash('id');
  my $first_name = $self->param('first_name');
  my $last_name  = $self->param('last_name');
  my $sth = $dbh->prepare(qq(UPDATE actor SET first_name = '$first_name', last_name = '$last_name' WHERE actor_id = $id));
  my $rv  = $sth->execute() or die $DBI::errstr;
  ($rv < 0) ? print $DBI::errstr : print "Operation done successfully\n";
  $sth->finish();
  $dbh->disconnect();
  # Lưu thông báo vào flash và chuyển hướng đến trang hiển thị danh sách bảng ghi
  $self->flash(success => 'Cập nhập thành công actor');
  return $self->redirect_to('/');
}
# Action Delete
sub delete {
  my $self = shift;
  my $dbh  = connect_db_pg();
  my $id   = $self->stash('id');
  my $sth  = $dbh->prepare(qq(DELETE FROM actor WHERE actor_id = $id;));
  my $rv   = $sth->execute() or die $DBI::errstr;
  ($rv < 0) ? print $DBI::errstr : print "Operation done successfully\n";
  $sth->finish();
  $dbh->disconnect();
  $self->flash(success => 'Xóa thành công actor');
  return $self->redirect_to('/');
}
1;
