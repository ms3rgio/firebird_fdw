Summary: A PostgreSQL foreign data wrapper (FDW) for Firebird
Name: postgresql95-firebird_fdw
Version: 0.5.0
Release: 1
Source: firebird_fdw-%{version}.tar.gz
URL: https://github.com/ibarwick/firebird_fdw
License: PostgreSQL
Group: Productivity/Databases/Tools
Packager: Ian Barwick
BuildRequires: postgresql95-devel firebird-devel
BuildRequires: libfq
BuildRoot: %{_tmppath}/%{name}-%{version}-build
Requires: postgresql95-server libfq

%define pgsql_path /usr/pgsql-9.5

%description
This is a foreign data wrapper (FDW) to connect PostgreSQL to Firebird.
It provides both read (SELECT) and write (INSERT/UPDATE/DELETE)
support, WHERE-clause pushdowns, connection caching and Firebird transaction
support.

This code is very much work-in-progress; USE AT YOUR OWN RISK.

%prep
%setup

%build
export PG_CONFIG=%{pgsql_path}/bin/pg_config
PG_CPPFLAGS="-I/usr/include/firebird" USE_PGXS=1 make

%install
rm -rf $RPM_BUILD_ROOT
export PG_CONFIG=%{pgsql_path}/bin/pg_config
USE_PGXS=1 make DESTDIR=$RPM_BUILD_ROOT install

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-, root, root)
%{pgsql_path}/lib/firebird_fdw.so
%{pgsql_path}/share/extension/firebird_fdw--0.3.0.sql
%{pgsql_path}/share/extension/firebird_fdw--0.3.0--0.4.0.sql
%{pgsql_path}/share/extension/firebird_fdw--0.4.0.sql
%{pgsql_path}/share/extension/firebird_fdw--0.4.0--0.5.0.sql
%{pgsql_path}/share/extension/firebird_fdw--0.5.0.sql
%{pgsql_path}/share/extension/firebird_fdw.control

%changelog
* Fri Oct 12 2018 Ian Barwick (barwick@gmail.com)
- 0.5.0 release
* Tue Oct 2 2018 Ian Barwick (barwick@gmail.com)
- 0.4.0 release
* Sun Apr 22 2018 Ian Barwick (barwick@gmail.com)
- 0.3.0 release
* Sun Feb 2 2014 Ian Barwick (barwick@gmail.com)
- First draft
