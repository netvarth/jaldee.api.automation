*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords     Delete All Sessions
...               AND           Remove File  cookies.txt
Force Tags        Waitlist
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Test Cases ***

JD-TC-Communication Between Provider And Consumer-1
	[Documentation]   Communication between provider and consumer after waitlist operation


    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}
***comment***
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${cookie}  ${resp}=   Imageupload.spLogin  5580861546  Netvarth1
    Log  ${resp.json()}
    ${caption}=  Fakerlibrary.sentence
    
    Set Suite Variable  ${uid}  "fdsfgdsgdsg"
    custuomField1   ${cookie}  ${uid}  ${messga}  ${caption}