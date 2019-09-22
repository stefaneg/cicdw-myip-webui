FROM gulli/cloudformation-deployer:0.1-7

ADD . .

ENTRYPOINT ["./deploy-web.sh"]

