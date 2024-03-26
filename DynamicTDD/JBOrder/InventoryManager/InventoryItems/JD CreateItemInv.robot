*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        ITEM 
Library           Collections
Library           String
Library           json
Library           DateTime
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_musers.py

*** Test Cases ***

JD-TC-UpdateItemGroupStatus-1

    [Documentation]   Update Item Group Status

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${displayName}=     FakerLibrary.name

    ${resp}=    Create Item Inventory  ${displayName}  itemCode=1111   categoryCode=35345  categoryCode2=78945   typeCode=64563   typeCode2=64563 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200