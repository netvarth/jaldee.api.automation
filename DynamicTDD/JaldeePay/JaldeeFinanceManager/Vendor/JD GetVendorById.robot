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


JD-TC-GetVendorById-1

    [Documentation]  Create Vendor for an SP and verify the details.

    ${resp}=  Provider Login  ${PUSERNAME103}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}
    
    ${name}=   FakerLibrary.word
    ${resp}=  Create Category   ${name}  ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id1}   ${resp.json()}

    ${resp}=  Get Category By Id   ${category_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}          ${name}
    Should Be Equal As Strings  ${resp.json()['categoryType']}  ${categoryType[0]}
    Should Be Equal As Strings  ${resp.json()['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()['status']}        ${toggle[0]}

    ${vender_name}=   FakerLibrary.firstname
    ${contactPersonName}=   FakerLibrary.lastname
    ${owner_name}=   FakerLibrary.lastname
    ${vendorId}=   FakerLibrary.word
    ${PO_Number}    Generate random string    5    123456789
    ${vendor_phn}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Set Suite Variable    ${vendor_phn}
    ${vendor_phno}=  Create Dictionary  countryCode=${countryCodes[0]}   number=${vendor_phn}
    Set Test Variable  ${email}  ${vender_name}${vendor_phn}.${test_mail}
    ${address}=  FakerLibrary.city
    ${bank_accno}=   db.Generate_random_value  size=11   chars=${digits} 
    ${branch}=   db.get_place
    ${ifsc_code}=   db.Generate_ifsc_code
    # ${gst_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}

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
    ${resp}=  Create Vendor  ${category_id1}  ${vendorId}  ${vender_name}   ${contactPersonName}    ${address}    ${state}    ${pin}   ${vendor_phno}   ${email}     bankInfo=${bankInfo}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${vendor_uid1}   ${resp.json()['uid']}
    Set Suite Variable   ${vendor_id1}   ${resp.json()['id']}

    ${resp}=  Get Vendor By Id   ${vendor_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${vendor_id1}
    Should Be Equal As Strings  ${resp.json()['accountId']}  ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorType']}  ${category_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorTypeName']}  ${name}
    Should Be Equal As Strings  ${resp.json()['vendorId']}  ${vendorId}
    Should Be Equal As Strings  ${resp.json()['vendorName']}  ${vender_name}
    Should Be Equal As Strings  ${resp.json()['contactPersonName']}  ${contactPersonName}
    Should Be Equal As Strings  ${resp.json()['vendorUid']}  ${vendor_uid1}

    Should Be Equal As Strings  ${resp.json()['bankInfo'][0]['bankaccountNo']}  ${bank_accno}
    Should Be Equal As Strings  ${resp.json()['bankInfo'][0]['ifscCode']}  ${bankIfsc}
    Should Be Equal As Strings  ${resp.json()['bankInfo'][0]['bankName']}  ${bankName}
    Should Be Equal As Strings  ${resp.json()['bankInfo'][0]['upiId']}  ${upiId}
    Should Be Equal As Strings  ${resp.json()['bankInfo'][0]['branchName']}  ${branchName}
    Should Be Equal As Strings  ${resp.json()['bankInfo'][0]['pancardNo']}  ${pan}
    Should Be Equal As Strings  ${resp.json()['bankInfo'][0]['gstNumber']}  ${gstin}
    Should Be Equal As Strings  ${resp.json()['bankInfo'][0]['preferredPaymentMode'][0]}  ${preferredPaymentMode[0]}
    Should Be Equal As Strings  ${resp.json()['bankInfo'][0]['lastPaymentModeUsed']}  ${jaldeePaymentmode[0]}

    Should Be Equal As Strings  ${resp.json()['contactInfo']['address']}  ${address}
    Should Be Equal As Strings  ${resp.json()['contactInfo']['state']}  ${state}
    Should Be Equal As Strings  ${resp.json()['contactInfo']['pincode']}  ${pin}
    Should Be Equal As Strings  ${resp.json()['contactInfo']['phoneNumbers'][0]['number']}    ${vendor_phn}
    Should Be Equal As Strings  ${resp.json()['contactInfo']['emails'][0]}  ${email[0]}
    Should Be Equal As Strings  ${resp.json()['status']}  ${toggle[0]}
    # Should Be Equal As Strings  ${resp.json()['createdDate']}  ${vendor_id1}

JD-TC-GetVendorById-2

    [Documentation]  Create multiple Vendor for an SP and verify the details.

    ${resp}=  Provider Login  ${PUSERNAME103}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

   
    ${name}=   FakerLibrary.word
    Set Test Variable   ${name}   
    ${resp}=  Create Category   ${name}  ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${category_id2}   ${resp.json()}

    ${resp}=  Get Category By Id   ${category_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}          ${name}
    Should Be Equal As Strings  ${resp.json()['categoryType']}  ${categoryType[0]}
    Should Be Equal As Strings  ${resp.json()['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()['status']}        ${toggle[0]}

    ${vender_name}=   FakerLibrary.firstname
    ${contactPersonName}=   FakerLibrary.lastname
    ${owner_name}=   FakerLibrary.lastname
    ${vendorId}=   FakerLibrary.word
    ${PO_Number}    Generate random string    5    123456789
    ${vendor_phn}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${vendor_phno}=  Create Dictionary  countryCode=${countryCodes[0]}   number=${vendor_phn}
    Set Test Variable  ${email}  ${vender_name}${vendor_phn}.${test_mail}
    ${address}=  FakerLibrary.city
    ${bank_accno}=   db.Generate_random_value  size=11   chars=${digits} 
    ${branch}=   db.get_place
    ${ifsc_code}=   db.Generate_ifsc_code
    # ${gst_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}

    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc

    ${state}=    Evaluate     "${state}".title()
    ${state}=    String.RemoveString  ${state}    ${SPACE}
    Set Test Variable    ${state}
    Set Test Variable    ${district}
    Set Test Variable    ${pin}
    ${vendor_phno}=   Create List  ${vendor_phno}
    Set Test Variable    ${vendor_phno}
    
    ${email}=   Create List  ${email}
    Set Test Variable    ${email}

    ${bankIfsc}    Random Number 	digits=5 
    ${bankIfsc}=    Evaluate    f'{${bankIfsc}:0>7d}'
    Log  ${bankIfsc}
    Set Test Variable  ${bankIfsc}  55555${bankIfsc} 

    ${bankName}     FakerLibrary.name
    Set Test Variable    ${bankName}
    ${upiId}     FakerLibrary.name
    Set Test Variable  ${upiId}

    ${pan}    Random Number 	digits=5 
    ${pan}=    Evaluate    f'{${pan}:0>5d}'
    Log  ${pan}
    Set Test Variable  ${pan}  55555${pan}

    ${branchName}=    FakerLibrary.name
    Set Test Variable  ${branchName}
    ${gstin}    Random Number 	digits=5 
    ${gstin}=    Evaluate    f'{${gstin}:0>8d}'
    Log  ${gstin}
    Set Test Variable  ${gstin}  55555${gstin}

    ${preferredPaymentMode}=    Create List    ${jaldeePaymentmode[0]}
    ${bankInfo}=    Create Dictionary     bankaccountNo=${bank_accno}    ifscCode=${bankIfsc}    bankName=${bankName}    upiId=${upiId}     branchName=${branchName}    pancardNo=${pan}    gstNumber=${gstin}    preferredPaymentMode=${preferredPaymentMode}    lastPaymentModeUsed=${jaldeePaymentmode[0]}
    ${bankInfo}=    Create List         ${bankInfo}     
    ${resp}=  Create Vendor  ${category_id2}  ${vendorId}  ${vender_name}   ${contactPersonName}    ${address}    ${state}    ${pin}   ${vendor_phno}   ${email}     bankInfo=${bankInfo}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${vendor_uid2}   ${resp.json()['uid']}
    Set Suite Variable   ${vendor_id2}   ${resp.json()['id']}

    ${resp}=  Get Vendor By Id   ${vendor_uid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${vendor_id2}
    Should Be Equal As Strings  ${resp.json()['accountId']}  ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorType']}  ${category_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorTypeName']}  ${name}
    Should Be Equal As Strings  ${resp.json()['vendorId']}  ${vendorId}
    Should Be Equal As Strings  ${resp.json()['vendorName']}  ${vender_name}
    Should Be Equal As Strings  ${resp.json()['contactPersonName']}  ${contactPersonName}
    Should Be Equal As Strings  ${resp.json()['vendorUid']}  ${vendor_uid2}

    Should Be Equal As Strings  ${resp.json()['bankInfo'][0]['bankaccountNo']}  ${bank_accno}
    Should Be Equal As Strings  ${resp.json()['bankInfo'][0]['ifscCode']}  ${bankIfsc}
    Should Be Equal As Strings  ${resp.json()['bankInfo'][0]['bankName']}  ${bankName}
    Should Be Equal As Strings  ${resp.json()['bankInfo'][0]['upiId']}  ${upiId}
    Should Be Equal As Strings  ${resp.json()['bankInfo'][0]['branchName']}  ${branchName}
    Should Be Equal As Strings  ${resp.json()['bankInfo'][0]['pancardNo']}  ${pan}
    Should Be Equal As Strings  ${resp.json()['bankInfo'][0]['gstNumber']}  ${gstin}
    Should Be Equal As Strings  ${resp.json()['bankInfo'][0]['preferredPaymentMode'][0]}  ${preferredPaymentMode[0]}
    Should Be Equal As Strings  ${resp.json()['bankInfo'][0]['lastPaymentModeUsed']}  ${jaldeePaymentmode[0]}

    Should Be Equal As Strings  ${resp.json()['contactInfo']['address']}  ${address}
    Should Be Equal As Strings  ${resp.json()['contactInfo']['state']}  ${state}
    Should Be Equal As Strings  ${resp.json()['contactInfo']['pincode']}  ${pin}
    Should Be Equal As Strings  ${resp.json()['contactInfo']['phoneNumbers'][0]['number']}    ${vendor_phn}
    Should Be Equal As Strings  ${resp.json()['contactInfo']['emails'][0]}  ${email[0]}
    Should Be Equal As Strings  ${resp.json()['status']}  ${toggle[0]}
    # Should Be Equal As Strings  ${resp.json()['createdDate']}  ${vendor_id1}

JD-TC-GetVendorById-UH1

    [Documentation]  Get Vendor without login.

    ${resp}=  Get Vendor By Id   ${vendor_uid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-GetVendorById-UH2

    [Documentation]  Get Vendor with another login.

    ${resp}=  Provider Login  ${PUSERNAME135}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}

    ${resp}=  Get Vendor By Id   ${vendor_uid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_VENDOR}"

JD-TC-GetVendorById-UH3

    [Documentation]  Get Vendor with consumer login.

     ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Vendor By Id   ${vendor_uid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}

