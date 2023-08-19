*** Settings ***
Library           Collections
Library           FakerLibrary
Library           json
Library           /ebs/TDD/db.py

*** Variables ***
${en_id1}      26


*** Keywords ***
Assigning Branches to Users

    [Arguments]    ${userids}    @{branches}

    ${len}=  Get Length  ${branches}
    
    ${data}=  Create Dictionary    userIds=${userids}    branchIds=${branches}
    Log  ${data}
    ${data}=    json.dumps    ${data}
    Log  ${data}
    

    Log  ${branches}


*** Test Cases ***

Assign branch keyword input

    ${userids}=  Create List  ${userid1}   ${userid2}

    ${branch1}=  Create Dictionary   id=${branchid1}    isDefault=True
    ${branch2}=  Create Dictionary   id=${branchid2}    isDefault=False
    ${branch3}=  Create Dictionary   id=${branchid3}    isDefault=False
    ${branch4}=  Create Dictionary   id=${branchid4}    isDefault=False

    Assigning Branches to Users    ${userids}  ${branch1}  ${branch2}  ${branch3}  ${branch4}

***Comment***

Checking verify account function

    ${otp}=   verify accnt  1113366591  2

# Testing string conversion
#     ${Result}=    Evaluate    f'{${en_id1}:05d}'
#     Log  ${Result}
#     ${PO_Number1}    Random Number 	digits=5  #fix_len=True
#     # ${PO_Number1}=  Convert To String  ${PO_Number1}
#     ${PO_Number}=    Evaluate    f'{${PO_Number1}:0>7d}'
#     Log  ${PO_Number}
#     ${PO_Number}=  Convert To String  ${PO_Number}
#     ${Result}=    Evaluate    f'{${PO_Number}:5>10d}'
#     Log  ${Result}
#     # ${Result}=    Evaluate    f'{${en_id1}:05d}'
#     # Log  ${Result}
#     # ${Result}=    Evaluate    f'{$en_id1:05d}'
#     # Log  ${Result}
    