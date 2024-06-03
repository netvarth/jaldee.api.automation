*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords  Delete All Sessions
Force Tags        Membership Service
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           RequestsLibrary
Library           OperatingSystem
Library           /ebs/TDD/excelfuncs.py
Library		      /ebs/TDD/Imageupload.py
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Test Cases ***


JD-TC-LoginVerification-1

    [Documentation]  login with ${PUSERNAME42}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME42}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Run Keyword And Continue On Failure  Set Test Variable  ${pid}  ${decrypted_data['id']}
    Run Keyword And Continue On Failure  Set Test Variable  ${firstname}  ${decrypted_data['firstName']}  
    Run Keyword And Continue On Failure  Set Test Variable  ${lastname}  ${decrypted_data['lastName']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['userName']}  ${firstname}${SPACE}${lastname}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['primaryPhoneNumber']}  ${PUSERNAME42}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['userType']}  1
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['userTypeEnum']}  ${userType[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accStatus']}  ${status[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['s3Url']}  https://jaldeelocal.s3.us-west-1.amazonaws.com
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['isProvider']}  ${bool[1]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['sector']}  foodJoints
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['subSector']}  coffeeShop
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['accountLicense']['accountLicId']}  203
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}  1
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['accountLicense']['base']}  ${bool[1]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['accountLicense']['licenseTransactionType']}  New
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['accountLicense']['renewedDays']}  0
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['accountLicense']['renewedBy']}  Asha
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['accountLicense']['type']}  Production
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['accountLicense']['status']}  Active
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['accountLicense']['name']}  Starter
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['accountLicense']['displayName']}  Starter
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['accountLicense']['invoicePending']}  ${bool[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgLevel']}  4
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons']}  []
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['dueAmount']}  0.0
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['firstCheckIn']}  ${bool[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountType']}  INDEPENDENT_SP
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['bProfileCreated']}  ${bool[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['securedUniquekey']}  7257bf2
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['adminPrivilege']}  ${bool[1]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['deptId']}  0
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['userTeams']}  []
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['bussLocs']}  [203]
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['showCsmrDataBase']}  ${bool[1]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['enableRbac']}  ${bool[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['multiFactorAuthenticationRequired']}  ${bool[0]}
    Run Keyword And Continue On Failure  Should Contain    ${decrypted_data['accountLicenseDetails']['accountLicense']}  dateApplied
    Run Keyword And Continue On Failure  Should Contain    ${decrypted_data['accountLicenseDetails']}  nextPaymentOn
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][0]['accountLicId']}  3
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][0]['licPkgOrAddonId']}  13
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][0]['base']}  ${bool[0]}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][0]['licenseTransactionType']}  New
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][0]['renewedDays']}  0
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][0]['renewedBy']}  Asha
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][0]['type']}  Production
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][0]['status']}  ${status[0]}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][0]['name']}  QBoards - 100 Count
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][0]['description']}  100 QBoards for Rs. 19999 per month
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][0]['metricIdOfAddon']}  18
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][0]['metricValueType']}  Number
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][0]['addonValue']}  100
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][0]['invoicePending']}  ${bool[0]}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][0]['licPkgLevel']}  0
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][1]['accountLicId']}  4
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][1]['licPkgOrAddonId']}  31
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][1]['base']}  ${bool[0]}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][1]['licenseTransactionType']}  New
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][1]['renewedDays']}  0
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][1]['renewedBy']}  Asha
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][1]['type']}  Production
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][1]['status']}  ${status[0]}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][1]['name']}  Multi User - 1000 Count
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][1]['description']}  Pack of 1000 Users for Rs. 399999 per month
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][1]['metricIdOfAddon']}  21
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][1]['metricValueType']}  Number
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][1]['addonValue']}  1000
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][1]['invoicePending']}  ${bool[0]}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][1]['licPkgLevel']}  0
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][2]['accountLicId']}  5
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][2]['licPkgOrAddonId']}  42
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][2]['base']}  ${bool[0]}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][2]['licenseTransactionType']}  New
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][2]['renewedDays']}  0
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][2]['renewedBy']}  Asha
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][2]['type']}  Production
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][2]['status']}  ${status[0]}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][2]['name']}  WhatsApp Message - 10000 Messages
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][2]['description']}  10000 WhatsApp Messages for Rs. 10000 per month
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][2]['metricIdOfAddon']}  27
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][2]['metricValueType']}  Number
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][2]['addonValue']}  10000.0
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][2]['invoicePending']}  ${bool[0]}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${decrypted_data['accountLicenseDetails']['addons'][2]['licPkgLevel']}  0
    
    
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  