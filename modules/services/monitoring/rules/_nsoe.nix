{ lib, ... }:
{
  groups = lib.singleton {
    name = "nam-shub-of-enki";
    rules = [
      {
        alert = "lot-of-bots";
        expr = ''(sum by(instance) (rate(nam_shub_of_enki_ruleset_hits{outcome!="not-for-us"}[1h]))) > 100'';
        for = "0s";
        labels.severity = "warning";
        annotations = {
          summary = "{{$labels.instance}}: more than 100 r/s of confirmed bots (iocaine)";
        };
      }
      {
        alert = "lot-of-requests";
        expr = "(sum by(instance) (rate(nam_shub_of_enki_requests[1h]))) > 300";
        for = "0s";
        labels.severity = "warning";
        annotations = {
          summary = "{{$labels.instance}}: more than 300 r/s of traffic (iocaine)";
        };
      }
      {
        alert = "lot-of-blocks";
        expr = "sum by (instance) (rate(iocaine_firewall_blocks[1h])) > 10";
        for = "0s";
        labels.severity = "warning";
        annotations = {
          summary = "{{$labels.instance}}: big wave of firewall blocks ({{ $value }}). (iocaine)";
        };
      }
    ];
  };
}
