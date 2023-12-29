{
  clusterNodes = [
    {
      hostname = "utm-nixos1";
      ip = "10.211.55.9";
      etcd = true;
      controlPlane = true;
    }
    {
      hostname = "utm-nixos2";
      ip = "10.211.55.10";
      etcd = true;
      controlPlane = true;
      workerNode = true;
    }
    {
      hostname = "utm-nixos3";
      ip = "10.211.55.11";
      etcd = true;
      workerNode = true;
    }
  ];
}