Name:   mysql-libs-stub 
Version:        0.3
Release:        1%{?dist}
Summary:        Provides mysql-libs capability to comply with EL6 expectations. Requires mysql-shared (MariaDB-shared suffices, of course).

Group:          SkySQL, AB
License:        GPL

BuildArch: noarch

Requires:       MySQL-shared
Provides:       mysql-libs

%description
Stub package to provide the mysql-libs capability.

%files
