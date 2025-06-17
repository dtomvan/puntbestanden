{ self, inputs, ... }:
{
  perSystem =
    { system, ... }:
    {
      apps = (inputs.nixinate.nixinate.${system} self).nixinate;
    };
}
