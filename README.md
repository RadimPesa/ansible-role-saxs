# ansible-role-saxs
Saxs role made for West Life demo

## TOSCA template:
```
tosca_definitions_version: tosca_simple_yaml_1_0

imports:
  - indigo_custom_types: https://raw.githubusercontent.com/alpegon/tosca-types/master/custom_types.yaml

description: >
  TOSCA test for launching the apache server with the saxs application

topology_template:

  node_templates:

    apache:
      type: tosca.nodes.WebServer.Apache
      requirements:
        - host: web_server

    saxs:
      type: tosca.nodes.indigo.Saxs
      requirements:
        - host: web_server
      interfaces:
        Standard:
          configure:
            implementation: https://raw.githubusercontent.com/alpegon/tosca-types/master/artifacts/saxs/sax-basic-install.yml

    web_server:
      type: tosca.nodes.indigo.Compute
      capabilities:
        endpoint:
          properties:
            network_name: PUBLIC
            ports:
              http_port:
                protocol: tcp
                source: 80
              https_port:
                protocol: tcp
                source: 443
        # Host container properties
        host:
         properties:
           num_cpus: 1
           mem_size: 1 GB
        # Guest Operating System properties
        os:
          properties:
            # host Operating System image properties
            type: linux
            distribution: centos
            version: 7

  outputs:
    server_url:
      value: { concat: [ 'http://', get_attribute: [ web_server, public_address, 0 ] ] }
```
