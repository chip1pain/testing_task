### After creating Nginx ec2 - make sure , that ssh and http/s Inbound rules allowed with 0.0.0.0 address


### Use this to generate some access.log

wrk -t4 -c100 -d30s  http://<nginx-public-ip>

```bash
 brew install wrk
```

### Port-forward kibana ui, so you can connect 
```bash
kubectl  port-forward -n elastic-stack  svc/kibana-kibana  5601:5601  --address='0.0.0.0'
```

### Connect to Kibana , adn create  Data Views.. index name filebeat*
