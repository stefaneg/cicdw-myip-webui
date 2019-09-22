FROM gulli/cloudformation-deployer:0.1

ADD . .

ENTRYPOINT ["./deploy-web.sh"]

