path:

let
  startsWithUnderscore = name: builtins.substring 0 1 name == "_";
  isNixFile = name: builtins.match ".*\\.nix" name != null;

  collect = dir:
    let
      entries = builtins.readDir dir;
      names = builtins.attrNames entries;
    in
    builtins.concatLists (builtins.map (
      name:
      let
        kind = entries.${name};
        full = dir + "/${name}";
      in
      if startsWithUnderscore name then
        [ ]
      else if kind == "directory" then
        collect full
      else if (kind == "regular" || kind == "symlink") && isNixFile name then
        [ full ]
      else
        [ ]
    ) names);
in
collect path
