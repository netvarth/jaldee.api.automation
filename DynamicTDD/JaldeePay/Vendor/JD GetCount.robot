*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Finance Manager
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 




*** Test Cases ***


JD-TC-Get Vendor List with Count filter-1

    [Documentation]  Create Vendor for an SP and get without filter parameter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME205}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=  Populate Url For Vendor   ${account_id1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

     
    ${name}=   FakerLibrary.word
    Set Suite Variable   ${name}   
    ${resp}=  CreateVendorCategory  ${name}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id1}   ${resp.json()}

    ${resp}=  Get by encId  ${category_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${id}   ${resp.json()['id']}
    Should Be Equal As Strings  ${resp.json()['name']}          ${name}
    Should Be Equal As Strings  ${resp.json()['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()['status']}        ${toggle[0]}

    ${vender_name}=   FakerLibrary.firstname
    Set Suite Variable    ${vender_name}
    ${contactPersonName}=   FakerLibrary.lastname
    Set Suite Variable    ${contactPersonName}
    ${vendorId}=   FakerLibrary.word
    Set Suite Variable    ${vendorId}
    ${PO_Number}    Generate random string    5    123456789
    ${vendor_phno}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${vendor_phno}=  Create Dictionary  countryCode=${countryCodes[0]}   number=${vendor_phno}
    Set Test Variable  ${email}  ${vender_name}.${test_mail}
    ${address}=  FakerLibrary.city
    Set Suite Variable  ${address}
    ${bank_accno}=   db.Generate_random_value  size=11   chars=${digits} 
    Set Suite Variable  ${bank_accno}
    ${branch}=   db.get_place
    ${ifsc_code}=   db.Generate_ifsc_code
    ${gst_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc

    ${state}=    Evaluate     "${state}".title()
    ${state}=    String.RemoveString  ${state}    ${SPACE}
    Set Suite Variable    ${state}
    Set Suite Variable    ${district}
    Set Suite Variable    ${pin}
    ${vendor_phno}=   Create List  ${vendor_phno}
    Set Suite Variable    ${vendor_phno}
    
    ${email}=   Create List  ${email}
    Set Suite Variable    ${email}

    ${bankIfsc}    Random Number 	digits=5 
    ${bankIfsc}=    Evaluate    f'{${bankIfsc}:0>7d}'
    Log  ${bankIfsc}
    Set Suite Variable  ${bankIfsc}  55555${bankIfsc} 

    ${bankName}     FakerLibrary.name
    Set Suite Variable    ${bankName}

    ${upiId}     FakerLibrary.name
    Set Suite Variable  ${upiId}

    ${pan}    Random Number 	digits=5 
    ${pan}=    Evaluate    f'{${pan}:0>5d}'
    Log  ${pan}
    Set Suite Variable  ${pan}  55555${pan}

    ${branchName}=    FakerLibrary.name
    Set Suite Variable  ${branchName}
    ${gstin}    Random Number 	digits=5 
    ${gstin}=    Evaluate    f'{${gstin}:0>8d}'
    Log  ${gstin}
    Set Suite Variable  ${gstin}  55555${gstin}

    ${preferredPaymentMode}=    Create List    ${jaldeePaymentmode[0]}
    ${bankInfo}=    Create Dictionary     bankaccountNo=${bank_accno}    ifscCode=${bankIfsc}    bankName=${bankName}    upiId=${upiId}     branchName=${branchName}    pancardNo=${pan}    gstNumber=${gstin}    preferredPaymentMode=${preferredPaymentMode}    lastPaymentModeUsed=${jaldeePaymentmode[0]}
    ${bankInfo}=    Create List         ${bankInfo}   
    Set Suite Variable  ${bankInfo}            
    ${resp}=  Create Vendor  ${category_id1}  ${vendorId}  ${vender_name}   ${contactPersonName}    ${address}    ${state}    ${pin}   ${vendor_phno}   ${email}     bankInfo=${bankInfo}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable            ${vendor_uid1}         ${resp.json()['encId']}
    Set Suite Variable            ${vendor_uid11}         ${resp.json()['uid']}
    Set Suite Variable            ${vendor_id1}          ${resp.json()['id']}


    ${resp}=   Get vendor by encId    ${vendor_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${vendorStatus}   ${resp.json()['vendorStatusName']}
    Should Be Equal As Strings  ${resp.json()['id']}  ${vendor_id1}
    Should Be Equal As Strings  ${resp.json()['accountId']}  ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorType']}  ${category_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorTypeName']}  ${name}
    Should Be Equal As Strings  ${resp.json()['vendorId']}  ${vendorId}
    Should Be Equal As Strings  ${resp.json()['vendorName']}  ${vender_name}
    Should Be Equal As Strings  ${resp.json()['contactPersonName']}  ${contactPersonName}
    Should Be Equal As Strings  ${resp.json()['vendorUid']}  ${vendor_uid11}
    Should Be Equal As Strings    ${resp.json()['categoryEncId']}                         ${category_id1}

    ${resp}=  Get Vendor List with Count filter
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1
JD-TC-Get Vendor List with Count filter-2

    [Documentation]  Create Vendor for an SP and get with filter -encid.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME205}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Vendor List with Count filter    encId-eq=${vendor_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get Vendor List with Count filter-3

    [Documentation]  Create Vendor for an SP and get with filter -vendorName.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME205}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Vendor List with Count filter    vendorName-eq=${vender_name}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get Vendor List with Count filter-4

    [Documentation]  Create Vendor for an SP and get with filter -vendorCategory.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME205}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Vendor List with Count filter    vendorCategory-eq=${id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get Vendor List with Count filter-5

    [Documentation]  Create Vendor for an SP and get with filter -bankinfo.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME205}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Vendor List with Count filter    bankInfo-eq=bankaccountNo::${bank_accno}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get Vendor List with Count filter-6

    [Documentation]  Create Vendor for an SP and get with filter -vendorId.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME205}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Vendor List with Count filter    vendorId-eq=${vendorId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get Vendor List with Count filter-7

    [Documentation]  Create Vendor for an SP and get with filter -contactPersonName.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME205}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Vendor List with Count filter    contactPersonName-eq=${contactPersonName}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get Vendor List with Count filter-8

    [Documentation]  Create Vendor for an SP and get with filter -contactinfo.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME205}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Vendor List with Count filter    contactInfo-eq=address::${address}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1
JD-TC-Get Vendor List with Count filter-9

    [Documentation]  Create Vendor for an SP and get with filter -userId.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME205}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Vendor List with Count filter    userId-eq=${account_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1
JD-TC-Get Vendor List with Count filter-10

    [Documentation]  Try to get filter with EMPTY -userId.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME205}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Vendor List with Count filter    userId-eq=${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  0

