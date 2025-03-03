{ hostname, lib, ... }: {
  age.secrets.keeshare.file = lib.mkIf (hostname == "tom-pc" || hostname == "tom-laptop") ../../secrets/keeshare.age;
}
