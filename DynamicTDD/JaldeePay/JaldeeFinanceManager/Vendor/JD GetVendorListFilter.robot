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

*** Keywords ***

Get Vendor List with filter
    [Arguments]   &{param}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /provider/jp/finance/vendor    params=${param}    expected_status=any    headers=${headers}
    [Return]  ${resp}


*** Test Cases ***


JD-TC-GetVendorListWithFilter-1

    [Documentation]  Create Vendor for an SP and get without filter parameter.

    ${resp}=  Provider Login  ${PUSERNAME77}  ${PASSWORD}
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
    Set Suite Variable   ${name}
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
    Set Suite Variable  ${vender_name}
    ${contactPersonName}=   FakerLibrary.lastname
    Set Suite Variable  ${contactPersonName}
    ${owner_name}=   FakerLibrary.lastname
    Set Suite Variable  ${owner_name}
    ${vendorId}=   FakerLibrary.word
    Set Suite Variable  ${vendorId}
    ${PO_Number}    Generate random string    5    123456789
    Set Suite Variable  ${PO_Number}
    ${vendor_phno}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Set Suite Variable  ${vendor_phno}
    Set Suite Variable  ${email}  ${vender_name}${vendor_phno}.${test_mail}
    ${address}=  FakerLibrary.city
    Set Suite Variable  ${address}
    ${bank_accno}=   db.Generate_random_value  size=11   chars=${digits} 
    Set Suite Variable  ${bank_accno}
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
    Set Suite Variable  ${userId}   ${resp.json()['userId']}
    Set Suite Variable  ${vendorStatus}   ${resp.json()['vendorStatus']}
    Set Suite Variable  ${vendorStatusName}   ${resp.json()['vendorStatusName']}
    Should Be Equal As Strings  ${resp.json()['id']}  ${vendor_id1}
    Should Be Equal As Strings  ${resp.json()['accountId']}  ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorType']}  ${category_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorTypeName']}  ${name}
    Should Be Equal As Strings  ${resp.json()['vendorId']}  ${vendorId}
    Should Be Equal As Strings  ${resp.json()['vendorName']}  ${vender_name}
    Should Be Equal As Strings  ${resp.json()['contactPersonName']}  ${contactPersonName}
    Should Be Equal As Strings  ${resp.json()['vendorUid']}  ${vendor_uid1}

    ${resp}=  Get Vendor List with filter
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${vendor_id1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['vendorType']}  ${category_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['vendorTypeName']}  ${name}
    Should Be Equal As Strings  ${resp.json()[0]['vendorId']}  ${vendorId}
    Should Be Equal As Strings  ${resp.json()[0]['vendorName']}  ${vender_name}
    Should Be Equal As Strings  ${resp.json()[0]['contactPersonName']}  ${contactPersonName}
    Should Be Equal As Strings  ${resp.json()[0]['vendorUid']}  ${vendor_uid1}

JD-TC-GetVendorListWithFilter-2

    [Documentation]  Create Vendor for an SP and get with filter -vendorUid.

    ${resp}=  Provider Login  ${PUSERNAME77}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Vendor List with filter    vendorUid-eq=${vendor_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${vendor_id1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['vendorType']}  ${category_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['vendorTypeName']}  ${name}
    Should Be Equal As Strings  ${resp.json()[0]['vendorId']}  ${vendorId}
    Should Be Equal As Strings  ${resp.json()[0]['vendorName']}  ${vender_name}
    Should Be Equal As Strings  ${resp.json()[0]['contactPersonName']}  ${contactPersonName}
    Should Be Equal As Strings  ${resp.json()[0]['vendorUid']}  ${vendor_uid1}

JD-TC-GetVendorListWithFilter-3

    [Documentation]  Create Vendor for an SP and get with filter -vendorName.

    ${resp}=  Provider Login  ${PUSERNAME77}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Vendor List with filter    vendorName-eq=${vender_name}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${vendor_id1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['vendorType']}  ${category_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['vendorTypeName']}  ${name}
    Should Be Equal As Strings  ${resp.json()[0]['vendorId']}  ${vendorId}
    Should Be Equal As Strings  ${resp.json()[0]['vendorName']}  ${vender_name}
    Should Be Equal As Strings  ${resp.json()[0]['contactPersonName']}  ${contactPersonName}
    Should Be Equal As Strings  ${resp.json()[0]['vendorUid']}  ${vendor_uid1}

JD-TC-GetVendorListWithFilter-4

    [Documentation]  Create Vendor for an SP and get with filter -vendorCategory.

    ${resp}=  Provider Login  ${PUSERNAME77}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Vendor List with filter    vendorCategory-eq=${category_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${vendor_id1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['vendorType']}  ${category_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['vendorTypeName']}  ${name}
    Should Be Equal As Strings  ${resp.json()[0]['vendorId']}  ${vendorId}
    Should Be Equal As Strings  ${resp.json()[0]['vendorName']}  ${vender_name}
    Should Be Equal As Strings  ${resp.json()[0]['contactPersonName']}  ${contactPersonName}
    Should Be Equal As Strings  ${resp.json()[0]['vendorUid']}  ${vendor_uid1}

JD-TC-GetVendorListWithFilter-5

    [Documentation]  Create Vendor for an SP and get with filter -vendorCategoryName.

    ${resp}=  Provider Login  ${PUSERNAME77}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Vendor List with filter    vendorCategoryName-eq=${name}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${vendor_id1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['vendorType']}  ${category_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['vendorTypeName']}  ${name}
    Should Be Equal As Strings  ${resp.json()[0]['vendorId']}  ${vendorId}
    Should Be Equal As Strings  ${resp.json()[0]['vendorName']}  ${vender_name}
    Should Be Equal As Strings  ${resp.json()[0]['contactPersonName']}  ${contactPersonName}
    Should Be Equal As Strings  ${resp.json()[0]['vendorUid']}  ${vendor_uid1}

JD-TC-GetVendorListWithFilter-6

    [Documentation]  Create Vendor for an SP and get with filter -vendorId.

    ${resp}=  Provider Login  ${PUSERNAME77}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Vendor List with filter    vendorId-eq=${vendorId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${vendor_id1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['vendorType']}  ${category_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['vendorTypeName']}  ${name}
    Should Be Equal As Strings  ${resp.json()[0]['vendorId']}  ${vendorId}
    Should Be Equal As Strings  ${resp.json()[0]['vendorName']}  ${vender_name}
    Should Be Equal As Strings  ${resp.json()[0]['contactPersonName']}  ${contactPersonName}
    Should Be Equal As Strings  ${resp.json()[0]['vendorUid']}  ${vendor_uid1}

JD-TC-GetVendorListWithFilter-7

    [Documentation]  Create Vendor for an SP and get with filter -contactPersonName.

    ${resp}=  Provider Login  ${PUSERNAME77}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Vendor List with filter    contactPersonName-eq=${contactPersonName}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${vendor_id1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['vendorType']}  ${category_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['vendorTypeName']}  ${name}
    Should Be Equal As Strings  ${resp.json()[0]['vendorId']}  ${vendorId}
    Should Be Equal As Strings  ${resp.json()[0]['vendorName']}  ${vender_name}
    Should Be Equal As Strings  ${resp.json()[0]['contactPersonName']}  ${contactPersonName}
    Should Be Equal As Strings  ${resp.json()[0]['vendorUid']}  ${vendor_uid1}

JD-TC-GetVendorListWithFilter-8

    [Documentation]  Create Vendor for an SP and get with filter -vendorStatus.

    ${resp}=  Provider Login  ${PUSERNAME77}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Vendor List with filter    vendorStatus-eq=${vendorStatus} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${vendor_id1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['vendorType']}  ${category_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['vendorTypeName']}  ${name}
    Should Be Equal As Strings  ${resp.json()[0]['vendorId']}  ${vendorId}
    Should Be Equal As Strings  ${resp.json()[0]['vendorName']}  ${vender_name}
    Should Be Equal As Strings  ${resp.json()[0]['contactPersonName']}  ${contactPersonName}
    Should Be Equal As Strings  ${resp.json()[0]['vendorUid']}  ${vendor_uid1}
    

JD-TC-GetVendorListWithFilter-9

    [Documentation]  Create Vendor for an SP and get with filter -userId.

    ${resp}=  Provider Login  ${PUSERNAME77}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Vendor List with filter    userId-eq=${userId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${vendor_id1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['vendorType']}  ${category_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['vendorTypeName']}  ${name}
    Should Be Equal As Strings  ${resp.json()[0]['vendorId']}  ${vendorId}
    Should Be Equal As Strings  ${resp.json()[0]['vendorName']}  ${vender_name}
    Should Be Equal As Strings  ${resp.json()[0]['contactPersonName']}  ${contactPersonName}
    Should Be Equal As Strings  ${resp.json()[0]['vendorUid']}  ${vendor_uid1}

JD-TC-GetVendorListWithFilter-10

    [Documentation]  Try to get filter with EMPTY -userId.

    ${resp}=  Provider Login  ${PUSERNAME77}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Vendor List with filter    userId-eq=${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetVendorListWithFilter-11

    [Documentation]  Create Vendor for an SP and get with filter -vendorStatusName.

    ${resp}=  Provider Login  ${PUSERNAME77}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Vendor List with filter    vendorStatusName-eq=${vendorStatusName} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${vendor_id1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['vendorType']}  ${category_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['vendorTypeName']}  ${name}
    Should Be Equal As Strings  ${resp.json()[0]['vendorId']}  ${vendorId}
    Should Be Equal As Strings  ${resp.json()[0]['vendorName']}  ${vender_name}
    Should Be Equal As Strings  ${resp.json()[0]['contactPersonName']}  ${contactPersonName}
    Should Be Equal As Strings  ${resp.json()[0]['vendorUid']}  ${vendor_uid1}

JD-TC-GetVendorListWithFilter-12

    [Documentation]  Create Vendor for an SP and get with filter -state

    ${resp}=  Provider Login  ${PUSERNAME77}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Vendor List with filter    contactInfo-eq=state::${state} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${vendor_id1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['vendorType']}  ${category_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['vendorTypeName']}  ${name}
    Should Be Equal As Strings  ${resp.json()[0]['vendorId']}  ${vendorId}
    Should Be Equal As Strings  ${resp.json()[0]['vendorName']}  ${vender_name}
    Should Be Equal As Strings  ${resp.json()[0]['contactPersonName']}  ${contactPersonName}
    Should Be Equal As Strings  ${resp.json()[0]['vendorUid']}  ${vendor_uid1}
    
JD-TC-GetVendorListWithFilter-13

    [Documentation]  Create Vendor for an SP and get with filter -bank_accno

    ${resp}=  Provider Login  ${PUSERNAME77}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Vendor List with filter    bankInfo-eq=bankaccountNo::${bank_accno} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${vendor_id1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['vendorType']}  ${category_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['vendorTypeName']}  ${name}
    Should Be Equal As Strings  ${resp.json()[0]['vendorId']}  ${vendorId}
    Should Be Equal As Strings  ${resp.json()[0]['vendorName']}  ${vender_name}
    Should Be Equal As Strings  ${resp.json()[0]['contactPersonName']}  ${contactPersonName}
    Should Be Equal As Strings  ${resp.json()[0]['vendorUid']}  ${vendor_uid1}
    

JD-TC-GetVendorListWithFilter-14

    [Documentation]  Create Vendor for an SP and get with filter -bankName

    ${resp}=  Provider Login  ${PUSERNAME77}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Vendor List with filter    bankInfo-eq=bankName::${bankName} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${vendor_id1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['vendorType']}  ${category_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['vendorTypeName']}  ${name}
    Should Be Equal As Strings  ${resp.json()[0]['vendorId']}  ${vendorId}
    Should Be Equal As Strings  ${resp.json()[0]['vendorName']}  ${vender_name}
    Should Be Equal As Strings  ${resp.json()[0]['contactPersonName']}  ${contactPersonName}
    Should Be Equal As Strings  ${resp.json()[0]['vendorUid']}  ${vendor_uid1}