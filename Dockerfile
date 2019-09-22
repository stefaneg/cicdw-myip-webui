FROM gulli/cloudformation-deployer:0.1-8

ADD . .

ENTRYPOINT ["./deploy-web.sh"]

