let
  containerPersonal = 1;
  containerWork = 2;

  spacePersonal = "82ec9321-5f58-4cf5-9d77-bf9964132163";
  spaceWork = "13e53f96-e5fd-48a6-86d7-0d9f094f0d1d";
in {
  settings = import ./_settings.nix;

  containersForce = true;
  containers = {
    Personal = {
      color = "purple";
      icon = "fingerprint";
      id = containerPersonal;
    };
    Work = {
      color = "blue";
      icon = "briefcase";
      id = containerWork;
    };
  };

  spaces = {
    Personal = {
      id = spacePersonal;
      container = containerPersonal;
      position = 1000;
    };
    Work = {
      id = spaceWork;
      container = containerWork;
      position = 2000;
    };
  };

  pinsForce = false;
  pins = {
    Claude = {
      id = "df97105d-ee9f-4ce4-9e10-117cc22f0722";
      workspace = spacePersonal;
      container = containerPersonal;
      url = "https://claude.ai/new";
      isEssential = true;
      position = 101;
    };
    DevTo = {
      id = "0df4d7f1-c2d5-4f33-b83a-6cffafefcaec";
      workspace = spacePersonal;
      container = containerPersonal;
      url = "https://dev.to/qcserestipy";
      isEssential = false;
      position = 102;
    };
    ChatGPT = {
      id = "afbe6f13-feb5-4726-a808-5e514f362d95";
      workspace = spacePersonal;
      container = containerPersonal;
      url = "https://chatgpt.com/";
      isEssential = true;
      position = 103;
    };
  };

  spacesForce = true;
}
