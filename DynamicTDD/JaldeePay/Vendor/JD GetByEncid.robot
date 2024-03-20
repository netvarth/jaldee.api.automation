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
*** Variables ***

${jpgfile}     /ebs/TDD/uploadimage.jpg
${pngfile}     /ebs/TDD/upload.png
${pdffile}     /ebs/TDD/sample.pdf
${jpgfile2}    /ebs/TDD/small.jpg
${gif}         /ebs/TDD/sample.gif
${xlsx}        /ebs/TDD/qnr.xlsx

${order}       0
${fileSize}    0.00458

*** Test Cases ***


JD-TC-GetEncById-1

    [Documentation]    Create Vendor then get vendor by id.

    ${resp}=                      Encrypted Provider Login         ${PUSERNAME207}    ${PASSWORD}
    Log                           ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}

    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Suite Variable    ${userName}    ${decrypted_data['userName']}
    Set Suite Variable    ${pdrfname}    ${decrypted_data['firstName']}
    Set Suite Variable    ${pdrlname}    ${decrypted_data['lastName']}

    ${resp}=                      Get Business Profile
    Log                           ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}     200
    Set Suite Variable            ${account_id1}          ${resp.json()['id']}

    ${resp}=  Populate Url For Vendor   ${account_id1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${name}=                      FakerLibrary.word
    Set Suite Variable            ${name}
    ${resp}=  CreateVendorCategory  ${name}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable            ${category_id1}        ${resp.json()}


    ${resp}=  Get by encId  ${category_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()['name']}            ${name}
    Should Be Equal As Strings    ${resp.json()['accountId']}       ${account_id1}
    Should Be Equal As Strings    ${resp.json()['status']}          ${toggle[0]}



    ${vender_name}=          FakerLibrary.firstname
    Set Suite Variable       ${vender_name}
    ${contactPersonName}=    FakerLibrary.lastname
    Set Suite Variable       ${contactPersonName}
    ${owner_name}=           FakerLibrary.lastname
    Set Suite Variable       ${owner_name}
    ${vendorId}=             FakerLibrary.word
    Set Suite Variable       ${vendorId}
    ${PO_Number}             Generate random string    5                                 123456789
    Set Suite Variable       ${PO_Number}
    ${vendor_ph}=            Evaluate                  ${PUSERNAME}+${PO_Number}
    Set Suite Variable    ${vendor_ph}

    ${vendor_phn}=          Create Dictionary         countryCode=${countryCodes[0]}    number=${vendor_ph}

    Set Suite Variable    ${vendor_phn}
    Set Suite Variable    ${email1}            ${vender_name}${vendor_ph}.${test_mail}
    ${address}=           FakerLibrary.city
    Set Suite Variable    ${address}

    ${bank_accno}=        db.Generate_random_value    size=11    chars=${digits} 
    Set Suite Variable    ${bank_accno}
    ${branch}=            db.get_place
    Set Suite Variable    ${branch}
    ${ifsc_code}=         db.Generate_ifsc_code
    Set Suite Variable    ${ifsc_code}
    # ${gst_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    # Set Suite Variable  ${gst_num}

    ${pin}    ${city}    ${district}    ${state}=    get_pin_loc

    ${state}=             Evaluate               "${state}".title()
    ${state}=             String.RemoveString    ${state}              ${SPACE}
    Set Suite Variable    ${state}
    Set Suite Variable    ${district}
    Set Suite Variable    ${pin}
    ${vendor_phno}=       Create List            ${vendor_phn}
    Set Suite Variable    ${vendor_phno}

    ${email}=             Create List    ${email1}
    Set Suite Variable    ${email}

    ${bankIfsc}           Random Number    digits=5 
    ${bankIfsc}=          Evaluate         f'{${bankIfsc}:0>7d}'
    Log                   ${bankIfsc}
    Set Suite Variable    ${bankIfsc}      55555${bankIfsc} 

    ${bankName}           FakerLibrary.name
    Set Suite Variable    ${bankName}
    ${upiId}              FakerLibrary.name
    Set Suite Variable    ${upiId}

    ${pan}                Random Number    digits=5 
    ${pan}=               Evaluate         f'{${pan}:0>5d}'
    Log                   ${pan}
    Set Suite Variable    ${pan}           55555${pan}

    ${branchName}=        FakerLibrary.name
    Set Suite Variable    ${branchName}
    ${gstin}              Random Number        digits=5 
    ${gstin}=             Evaluate             f'{${gstin}:0>8d}'
    Log                   ${gstin}
    Set Suite Variable    ${gstin}             55555${gstin}

    ${preferredPaymentMode}=      Create List            ${jaldeePaymentmode[0]}
    ${bankInfo}=                  Create Dictionary      bankaccountNo=${bank_accno}    ifscCode=${bankIfsc}    bankName=${bankName}    upiId=${upiId}          branchName=${branchName}    pancardNo=${pan}    gstNumber=${gstin}    preferredPaymentMode=${preferredPaymentMode}    lastPaymentModeUsed=${jaldeePaymentmode[0]}
    ${bankInfo}=                  Create List            ${bankInfo}                    
    Set Suite Variable            ${bankInfo}            
    ${resp}=                      Create Vendor          ${category_id1}                ${vendorId}             ${vender_name}          ${contactPersonName}    ${address}                  ${state}            ${pin}                ${vendor_phno}                                  ${email}                                       bankInfo=${bankInfo}    
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable            ${vendor_uid1}         ${resp.json()['encId']}
    Set Suite Variable            ${vendor_uid11}         ${resp.json()['uid']}
    Set Suite Variable            ${vendor_id1}          ${resp.json()['id']}

    ${resp}=                      Get vendor by encId                                 ${vendor_uid1}
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}                                 200
    Should Be Equal As Strings    ${resp.json()['id']}                                ${vendor_id1}
    Should Be Equal As Strings    ${resp.json()['accountId']}                         ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorType']}  ${category_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorTypeName']}  ${name}
    Should Be Equal As Strings    ${resp.json()['vendorId']}                          ${vendorId}
    Should Be Equal As Strings    ${resp.json()['vendorName']}                        ${vender_name}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['phoneNumbers'][0]['number']}    ${vendor_ph}
    Should Be Equal As Strings    ${resp.json()['contactPersonName']}                 ${contactPersonName}
    Should Be Equal As Strings    ${resp.json()['vendorUid']}                         ${vendor_uid11}
    Should Be Equal As Strings    ${resp.json()['categoryEncId']}                         ${category_id1}


JD-TC-GetEncById-2

    [Documentation]    update vendor then get vendor by encid.

    ${resp}=                      Encrypted Provider Login         ${PUSERNAME207}    ${PASSWORD}
    Log                           ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${preferredPaymentMode}=    Create List          ${jaldeePaymentmode[0]}
    # ${bankInfo}=                Create Dictionary    bankaccountNo=${bank_accno}    ifscCode=${bankIfsc}    bankName=${bankName}    upiId=${upiId}    branchName=${branchName}    pancardNo=${pan}    gstNumber=${gstin}    preferredPaymentMode=${preferredPaymentMode}    lastPaymentModeUsed=${jaldeePaymentmode[0]}
    # ${bankInfo}=                Create List          ${bankInfo}

    ${resp}=                      Update Vendor          ${vendor_uid1}    ${category_id1}    ${EMPTY}    ${vender_name}    ${contactPersonName}    ${address}    ${state}    ${pin}    ${vendor_phno}    ${email}    bankInfo=${bankInfo}    
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}     200


    ${resp}=                      Get vendor by encId                                  ${vendor_uid1}
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}                                 200
    Should Be Equal As Strings    ${resp.json()['id']}                                ${vendor_id1}
    Should Be Equal As Strings    ${resp.json()['accountId']}                         ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorType']}  ${category_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorTypeName']}  ${name}
    Should Be Equal As Strings    ${resp.json()['vendorId']}                          ${EMPTY}
    Should Be Equal As Strings    ${resp.json()['vendorName']}                        ${vender_name}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['phoneNumbers'][0]['number']}    ${vendor_ph}
    Should Be Equal As Strings    ${resp.json()['contactPersonName']}                 ${contactPersonName}
    Should Be Equal As Strings    ${resp.json()['vendorUid']}                         ${vendor_uid11}
    Should Be Equal As Strings    ${resp.json()['categoryEncId']}                         ${category_id1}
    Should Be Equal As Strings    ${resp.json()['encId']}                              ${vendor_uid1}

JD-TC-GetEncById-3

    [Documentation]    Try to Update vendor vendorCategory and then get encbyid.

    ${resp}=                      Encrypted Provider Login         ${PUSERNAME207}    ${PASSWORD}
    Log                           ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${preferredPaymentMode}=    Create List          ${jaldeePaymentmode[0]}
    ${bankInfo}=                Create Dictionary    bankaccountNo=${bank_accno}    ifscCode=${bankIfsc}    bankName=${bankName}    upiId=${upiId}    branchName=${branchName}    pancardNo=${pan}    gstNumber=${gstin}    preferredPaymentMode=${preferredPaymentMode}    lastPaymentModeUsed=${jaldeePaymentmode[0]}
    ${bankInfo}=                Create List          ${bankInfo} 

    ${name2}=                     FakerLibrary.word
    ${resp}=                       CreateVendorCategory        ${name2}         
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable            ${category_id3}        ${resp.json()}

    ${resp}=                      Get by encId                ${category_id3}
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}               200
    Should Be Equal As Strings    ${resp.json()['name']}            ${name2}
    Should Be Equal As Strings    ${resp.json()['accountId']}       ${account_id1}
    Should Be Equal As Strings    ${resp.json()['status']}          ${toggle[0]}          

    ${resp}=                      Update Vendor          ${vendor_uid1}    ${category_id3}    ${vendorId}    ${vender_name}    ${contactPersonName}    ${address}    ${state}    ${pin}    ${vendor_phno}    ${email}    bankInfo=${bankInfo}    
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=                      Get vendor by encId                                   ${vendor_uid1}
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}                                 200
    Should Be Equal As Strings    ${resp.json()['id']}                                ${vendor_id1}
    Should Be Equal As Strings    ${resp.json()['accountId']}                         ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorTypeName']}  ${name}
    Should Be Equal As Strings    ${resp.json()['vendorId']}                          ${vendorId}
    Should Be Equal As Strings    ${resp.json()['vendorName']}                        ${vender_name}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['phoneNumbers'][0]['number']}    ${vendor_ph}
    Should Be Equal As Strings    ${resp.json()['contactPersonName']}                 ${contactPersonName}
    Should Be Equal As Strings    ${resp.json()['vendorUid']}                         ${vendor_uid11}
    Should Be Equal As Strings    ${resp.json()['categoryEncId']}                         ${category_id3}
    Should Be Equal As Strings    ${resp.json()['encId']}                              ${vendor_uid1}

JD-TC-GetEncById-4

    [Documentation]    Try to Update vendor vendorName and then get encbyid.

    ${resp}=                      Encrypted Provider Login         ${PUSERNAME207}    ${PASSWORD}
    Log                           ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${preferredPaymentMode}=    Create List          ${jaldeePaymentmode[0]}
    # ${bankInfo}=                Create Dictionary    bankaccountNo=${bank_accno}    ifscCode=${bankIfsc}    bankName=${bankName}    upiId=${upiId}    branchName=${branchName}    pancardNo=${pan}    gstNumber=${gstin}    preferredPaymentMode=${preferredPaymentMode}    lastPaymentModeUsed=${jaldeePaymentmode[0]}
    # ${bankInfo}=                Create List          ${bankInfo}

    ${vender_name1}=    FakerLibrary.word

    ${resp}=                      Update Vendor          ${vendor_uid1}    ${category_id1}    ${vendorId}    ${vender_name1}    ${contactPersonName}    ${address}    ${state}    ${pin}    ${vendor_phno}    ${email}    bankInfo=${bankInfo}    
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=                      Get vendor by encId                                    ${vendor_uid1}
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}                                 200
    Should Be Equal As Strings    ${resp.json()['vendorName']}                        ${vender_name1}
    Should Be Equal As Strings    ${resp.json()['id']}                                ${vendor_id1}
    Should Be Equal As Strings    ${resp.json()['accountId']}                         ${account_id1}
    Should Be Equal As Strings    ${resp.json()['vendorId']}                          ${vendorId}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['phoneNumbers'][0]['number']}    ${vendor_ph}
    Should Be Equal As Strings    ${resp.json()['contactPersonName']}                 ${contactPersonName}
    Should Be Equal As Strings    ${resp.json()['vendorUid']}                         ${vendor_uid11}
    Should Be Equal As Strings    ${resp.json()['categoryEncId']}                         ${category_id1}
    Should Be Equal As Strings    ${resp.json()['encId']}                              ${vendor_uid1}
JD-TC-GetEncById-5

    [Documentation]    Try to Update vendor contactPersonName and then get encbyid.

    ${resp}=                      Encrypted Provider Login         ${PUSERNAME207}    ${PASSWORD}
    Log                           ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${preferredPaymentMode}=    Create List          ${jaldeePaymentmode[0]}
    # ${bankInfo}=                Create Dictionary    bankaccountNo=${bank_accno}    ifscCode=${bankIfsc}    bankName=${bankName}    upiId=${upiId}    branchName=${branchName}    pancardNo=${pan}    gstNumber=${gstin}    preferredPaymentMode=${preferredPaymentMode}    lastPaymentModeUsed=${jaldeePaymentmode[0]}
    # ${bankInfo}=                Create List          ${bankInfo}

    ${contactPersonName1}=    FakerLibrary.name

    ${resp}=                      Update Vendor          ${vendor_uid1}    ${category_id1}    ${vendorId}    ${vender_name}    ${contactPersonName1}    ${address}    ${state}    ${pin}    ${vendor_phno}    ${email}    bankInfo=${bankInfo}    
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=                      Get vendor by encId                                    ${vendor_uid1}
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}                                 200
    Should Be Equal As Strings    ${resp.json()['contactPersonName']}                 ${contactPersonName1}
    Should Be Equal As Strings    ${resp.json()['vendorName']}                        ${vender_name}
    Should Be Equal As Strings    ${resp.json()['id']}                                ${vendor_id1}
    Should Be Equal As Strings    ${resp.json()['accountId']}                         ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorTypeName']}  ${name}
    Should Be Equal As Strings    ${resp.json()['vendorId']}                          ${vendorId}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['phoneNumbers'][0]['number']}    ${vendor_ph}
    Should Be Equal As Strings    ${resp.json()['vendorUid']}                         ${vendor_uid11}
    Should Be Equal As Strings    ${resp.json()['categoryEncId']}                         ${category_id1}
    Should Be Equal As Strings    ${resp.json()['encId']}                              ${vendor_uid1}


JD-TC-GetEncById-6

    [Documentation]    Try to Update vendor addressand then get encbyid.

    ${resp}=                      Encrypted Provider Login         ${PUSERNAME207}    ${PASSWORD}
    Log                           ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${preferredPaymentMode}=    Create List          ${jaldeePaymentmode[0]}
    # ${bankInfo}=                Create Dictionary    bankaccountNo=${bank_accno}    ifscCode=${bankIfsc}    bankName=${bankName}    upiId=${upiId}    branchName=${branchName}    pancardNo=${pan}    gstNumber=${gstin}    preferredPaymentMode=${preferredPaymentMode}    lastPaymentModeUsed=${jaldeePaymentmode[0]}
    # ${bankInfo}=                Create List          ${bankInfo}
    ${address1}=    FakerLibrary.city

    ${resp}=                      Update Vendor          ${vendor_uid1}    ${category_id1}    ${vendorId}    ${vender_name}    ${contactPersonName}    ${address1}    ${state}    ${pin}    ${vendor_phno}    ${email}    bankInfo=${bankInfo}    
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=                      Get vendor by encId                                    ${vendor_uid1}
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}                                 200
    Should Be Equal As Strings    ${resp.json()['contactPersonName']}                 ${contactPersonName}
    Should Be Equal As Strings    ${resp.json()['vendorName']}                        ${vender_name}
    Should Be Equal As Strings    ${resp.json()['id']}                                ${vendor_id1}
    Should Be Equal As Strings    ${resp.json()['accountId']}                         ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorTypeName']}  ${name}
    Should Be Equal As Strings    ${resp.json()['vendorId']}                          ${vendorId}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['phoneNumbers'][0]['number']}    ${vendor_ph}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['address']}            ${address1}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['state']}              ${state}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['pincode']}            ${pin}
    Should Be Equal As Strings    ${resp.json()['vendorUid']}                         ${vendor_uid11}
    Should Be Equal As Strings    ${resp.json()['categoryEncId']}                         ${category_id1}
    Should Be Equal As Strings    ${resp.json()['encId']}                              ${vendor_uid1}

JD-TC-GetEncById-7

    [Documentation]    Try to Update vendor state and then get encbyid.

    ${resp}=                      Encrypted Provider Login         ${PUSERNAME207}    ${PASSWORD}
    Log                           ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${preferredPaymentMode}=    Create List          ${jaldeePaymentmode[0]}
    # ${bankInfo}=                Create Dictionary    bankaccountNo=${bank_accno}    ifscCode=${bankIfsc}    bankName=${bankName}    upiId=${upiId}    branchName=${branchName}    pancardNo=${pan}    gstNumber=${gstin}    preferredPaymentMode=${preferredPaymentMode}    lastPaymentModeUsed=${jaldeePaymentmode[0]}
    # ${bankInfo}=                Create List          ${bankInfo}
    ${state1}=    FakerLibrary.city

    ${resp}=                      Update Vendor          ${vendor_uid1}    ${category_id1}    ${vendorId}    ${vender_name}    ${contactPersonName}    ${address}    ${state1}    ${pin}    ${vendor_phno}    ${email}    bankInfo=${bankInfo}    
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=                      Get vendor by encId                                   ${vendor_uid1}
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}                                 200
    Should Be Equal As Strings    ${resp.json()['contactPersonName']}                 ${contactPersonName}
    Should Be Equal As Strings    ${resp.json()['vendorName']}                        ${vender_name}
    Should Be Equal As Strings    ${resp.json()['id']}                                ${vendor_id1}
    Should Be Equal As Strings    ${resp.json()['accountId']}                         ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorTypeName']}  ${name}
    Should Be Equal As Strings    ${resp.json()['vendorId']}                          ${vendorId}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['phoneNumbers'][0]['number']}    ${vendor_ph}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['address']}            ${address}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['state']}              ${state1}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['pincode']}            ${pin}
    Should Be Equal As Strings    ${resp.json()['vendorUid']}                         ${vendor_uid11}
    Should Be Equal As Strings    ${resp.json()['categoryEncId']}                         ${category_id1}
    Should Be Equal As Strings    ${resp.json()['encId']}                              ${vendor_uid1}

JD-TC-GetEncById-8

    [Documentation]    Try to Update vendor pincode  and then get encbyid..

    ${resp}=                      Encrypted Provider Login         ${PUSERNAME207}    ${PASSWORD}
    Log                           ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${preferredPaymentMode}=    Create List          ${jaldeePaymentmode[0]}
    # ${bankInfo}=                Create Dictionary    bankaccountNo=${bank_accno}    ifscCode=${bankIfsc}    bankName=${bankName}    upiId=${upiId}    branchName=${branchName}    pancardNo=${pan}    gstNumber=${gstin}    preferredPaymentMode=${preferredPaymentMode}    lastPaymentModeUsed=${jaldeePaymentmode[0]}
    # ${bankInfo}=                Create List          ${bankInfo}
    ${pin1}=    FakerLibrary.city

    ${resp}=                      Update Vendor          ${vendor_uid1}    ${category_id1}    ${vendorId}    ${vender_name}    ${contactPersonName}    ${address}    ${state}    ${pin1}    ${vendor_phno}    ${email}    bankInfo=${bankInfo}    
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=                      Get vendor by encId                                    ${vendor_uid1}
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}                                 200
    Should Be Equal As Strings    ${resp.json()['contactPersonName']}                 ${contactPersonName}
    Should Be Equal As Strings    ${resp.json()['vendorName']}                        ${vender_name}
    Should Be Equal As Strings    ${resp.json()['id']}                                ${vendor_id1}
    Should Be Equal As Strings    ${resp.json()['accountId']}                         ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorTypeName']}  ${name}
    Should Be Equal As Strings    ${resp.json()['vendorId']}                          ${vendorId}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['phoneNumbers'][0]['number']}    ${vendor_ph}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['address']}            ${address}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['state']}              ${state}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['pincode']}            ${pin1}
    Should Be Equal As Strings    ${resp.json()['vendorUid']}                         ${vendor_uid11}
    Should Be Equal As Strings    ${resp.json()['categoryEncId']}                         ${category_id1}
    Should Be Equal As Strings    ${resp.json()['encId']}                              ${vendor_uid1}

JD-TC-GetEncById-9

    [Documentation]    Try to Update vendor phoneNumbers and then get encbyid..

    ${resp}=                      Encrypted Provider Login         ${PUSERNAME207}    ${PASSWORD}
    Log                           ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${preferredPaymentMode}=    Create List          ${jaldeePaymentmode[0]}
    # ${bankInfo}=                Create Dictionary    bankaccountNo=${bank_accno}    ifscCode=${bankIfsc}    bankName=${bankName}    upiId=${upiId}    branchName=${branchName}    pancardNo=${pan}    gstNumber=${gstin}    preferredPaymentMode=${preferredPaymentMode}    lastPaymentModeUsed=${jaldeePaymentmode[0]}
    # ${bankInfo}=                Create List          ${bankInfo}
    ${pin1}=    FakerLibrary.city

    ${vendor_ph2}=        Evaluate           ${PUSERNAME}+1235246
    Set Suite Variable    ${vendor_ph2}

    ${vendor_ph1}=          Create Dictionary         countryCode=${countryCodes[0]}    number=${vendor_ph2}
    ${vendor_phno1}=      Create List        ${vendor_phn}            ${vendor_ph1}
    Set Suite Variable    ${vendor_phno1}

    ${resp}=                      Update Vendor          ${vendor_uid1}    ${category_id1}    ${vendorId}    ${vender_name}    ${contactPersonName}    ${address}    ${state}    ${pin}    ${vendor_phno1}    ${email}    bankInfo=${bankInfo}    
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=                      Get vendor by encId                                   ${vendor_uid1}
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}                                 200
    Should Be Equal As Strings    ${resp.json()['contactPersonName']}                 ${contactPersonName}
    Should Be Equal As Strings    ${resp.json()['vendorName']}                        ${vender_name}
    Should Be Equal As Strings    ${resp.json()['id']}                                ${vendor_id1}
    Should Be Equal As Strings    ${resp.json()['accountId']}                         ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorTypeName']}  ${name}
    Should Be Equal As Strings    ${resp.json()['vendorId']}                          ${vendorId}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['phoneNumbers'][0]['number']}    ${vendor_ph}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['phoneNumbers'][1]['number']}    ${vendor_ph2}

    Should Be Equal As Strings    ${resp.json()['contactInfo']['address']}    ${address}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['state']}      ${state}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['pincode']}    ${pin}
    Should Be Equal As Strings    ${resp.json()['vendorUid']}                 ${vendor_uid11}
    Should Be Equal As Strings    ${resp.json()['categoryEncId']}                         ${category_id1}
    Should Be Equal As Strings    ${resp.json()['encId']}                              ${vendor_uid1}




JD-TC-GetEncById-11

    [Documentation]    Try to Update vendor bankaccountNo  and then get encbyid..

    ${resp}=                      Encrypted Provider Login         ${PUSERNAME207}    ${PASSWORD}
    Log                           ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${bank_accno1}=    db.Generate_random_value    size=11    chars=${digits} 


    ${preferredPaymentMode}=    Create List          ${jaldeePaymentmode[0]}
    ${bankInfo}=                Create Dictionary    bankaccountNo=${bank_accno1}    ifscCode=${bankIfsc}    bankName=${bankName}    upiId=${upiId}    branchName=${branchName}    pancardNo=${pan}    gstNumber=${gstin}    preferredPaymentMode=${preferredPaymentMode}    lastPaymentModeUsed=${jaldeePaymentmode[0]}
    ${bankInfo}=                Create List          ${bankInfo}                     
    ${pin1}=                    FakerLibrary.city

    # ${vendor_ph2}=          Evaluate                  ${PUSERNAME}+1235246
    ${emails}=            Create List    ${email1}    
    Set Suite Variable    ${emails}

    ${resp}=                      Update Vendor          ${vendor_uid1}    ${category_id1}    ${vendorId}    ${vender_name}    ${contactPersonName}    ${address}    ${state}    ${pin}    ${vendor_phno1}    ${emails}    bankInfo=${bankInfo}    
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=                      Get vendor by encId                                   ${vendor_uid1}
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}                                 200
    Should Be Equal As Strings    ${resp.json()['contactPersonName']}                 ${contactPersonName}
    Should Be Equal As Strings    ${resp.json()['vendorName']}                        ${vender_name}
    Should Be Equal As Strings    ${resp.json()['id']}                                ${vendor_id1}
    Should Be Equal As Strings    ${resp.json()['accountId']}                         ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorTypeName']}  ${name}
    Should Be Equal As Strings    ${resp.json()['vendorId']}                          ${vendorId}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['phoneNumbers'][0]['number']}    ${vendor_ph}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['phoneNumbers'][1]['number']}    ${vendor_ph2}

    Should Be Equal As Strings    ${resp.json()['contactInfo']['emails'][0]}    ${emails[0]}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['address']}      ${address}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['state']}        ${state}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['pincode']}      ${pin}
    Should Be Equal As Strings    ${resp.json()['vendorUid']}                   ${vendor_uid11}
    Should Be Equal As Strings    ${resp.json()['categoryEncId']}                         ${category_id1}
    Should Be Equal As Strings    ${resp.json()['encId']}                              ${vendor_uid1}

    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['bankaccountNo']}    ${bank_accno1}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['ifscCode']}         ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['bankName']}         ${bankName}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['upiId']}            ${upiId}

    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['branchName']}    ${branchName}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['pancardNo']}     ${pan}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['gstNumber']}     ${gstin}

    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['preferredPaymentMode'][0]}    ${preferredPaymentMode[0]}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['lastPaymentModeUsed']}        ${jaldeePaymentmode[0]}

JD-TC-GetEncById-12

    [Documentation]    Try to Update vendor ifscCode  and then get encbyid..

    ${resp}=                      Encrypted Provider Login         ${PUSERNAME207}    ${PASSWORD}
    Log                           ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${bank_accno1}=    db.Generate_random_value    size=11    chars=${digits} 

    ${bankIfsc1}     Random Number    digits=5 
    ${bankIfsc1}=    Evaluate         f'{${bankIfsc1}:0>7d}'
    Log              ${bankIfsc1}


    ${preferredPaymentMode}=    Create List          ${jaldeePaymentmode[0]}
    ${bankInfo}=                Create Dictionary    bankaccountNo=${bank_accno1}    ifscCode=${bankIfsc1}    bankName=${bankName}    upiId=${upiId}    branchName=${branchName}    pancardNo=${pan}    gstNumber=${gstin}    preferredPaymentMode=${preferredPaymentMode}    lastPaymentModeUsed=${jaldeePaymentmode[0]}
    ${bankInfo}=                Create List          ${bankInfo}                     
    ${pin1}=                    FakerLibrary.city

    # ${vendor_ph2}=          Evaluate                  ${PUSERNAME}+1235246
    ${emails}=            Create List    ${email1}    
    Set Suite Variable    ${emails}

    ${resp}=                      Update Vendor          ${vendor_uid1}    ${category_id1}    ${vendorId}    ${vender_name}    ${contactPersonName}    ${address}    ${state}    ${pin}    ${vendor_phno1}    ${emails}    bankInfo=${bankInfo}    
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=                      Get vendor by encId                                   ${vendor_uid1}
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}                                 200
    Should Be Equal As Strings    ${resp.json()['contactPersonName']}                 ${contactPersonName}
    Should Be Equal As Strings    ${resp.json()['vendorName']}                        ${vender_name}
    Should Be Equal As Strings    ${resp.json()['id']}                                ${vendor_id1}
    Should Be Equal As Strings    ${resp.json()['accountId']}                         ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorTypeName']}  ${name}
    Should Be Equal As Strings    ${resp.json()['vendorId']}                          ${vendorId}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['phoneNumbers'][0]['number']}    ${vendor_ph}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['phoneNumbers'][1]['number']}    ${vendor_ph2}

    Should Be Equal As Strings    ${resp.json()['contactInfo']['emails'][0]}    ${emails[0]}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['address']}      ${address}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['state']}        ${state}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['pincode']}      ${pin}
    Should Be Equal As Strings    ${resp.json()['vendorUid']}                   ${vendor_uid11}
    Should Be Equal As Strings    ${resp.json()['categoryEncId']}                         ${category_id1}
    Should Be Equal As Strings    ${resp.json()['encId']}                              ${vendor_uid1}

    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['bankaccountNo']}    ${bank_accno1}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['ifscCode']}         ${bankIfsc1}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['bankName']}         ${bankName}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['upiId']}            ${upiId}

    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['branchName']}    ${branchName}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['pancardNo']}     ${pan}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['gstNumber']}     ${gstin}

    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['preferredPaymentMode'][0]}    ${preferredPaymentMode[0]}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['lastPaymentModeUsed']}        ${jaldeePaymentmode[0]}

JD-TC-GetEncById-13

    [Documentation]    Try to Update vendor bankName  and then get encbyid..

    ${resp}=                      Encrypted Provider Login         ${PUSERNAME207}    ${PASSWORD}
    Log                           ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${bank_accno1}=    db.Generate_random_value    size=11    chars=${digits} 

    ${bankIfsc1}     Random Number        digits=5 
    ${bankIfsc1}=    Evaluate             f'{${bankIfsc1}:0>7d}'
    Log              ${bankIfsc1}
    ${bankName1}     FakerLibrary.name


    ${preferredPaymentMode}=    Create List          ${jaldeePaymentmode[0]}
    ${bankInfo}=                Create Dictionary    bankaccountNo=${bank_accno1}    ifscCode=${bankIfsc1}    bankName=${bankName1}    upiId=${upiId}    branchName=${branchName}    pancardNo=${pan}    gstNumber=${gstin}    preferredPaymentMode=${preferredPaymentMode}    lastPaymentModeUsed=${jaldeePaymentmode[0]}
    ${bankInfo}=                Create List          ${bankInfo}                     
    ${pin1}=                    FakerLibrary.city

    # ${vendor_ph2}=          Evaluate                  ${PUSERNAME}+1235246
    ${emails}=            Create List    ${email1}    
    Set Suite Variable    ${emails}

    ${resp}=                      Update Vendor          ${vendor_uid1}    ${category_id1}    ${vendorId}    ${vender_name}    ${contactPersonName}    ${address}    ${state}    ${pin}    ${vendor_phno1}    ${emails}    bankInfo=${bankInfo}    
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=                      Get vendor by encId                                    ${vendor_uid1}
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}                                 200
    Should Be Equal As Strings    ${resp.json()['contactPersonName']}                 ${contactPersonName}
    Should Be Equal As Strings    ${resp.json()['vendorName']}                        ${vender_name}
    Should Be Equal As Strings    ${resp.json()['id']}                                ${vendor_id1}
    Should Be Equal As Strings    ${resp.json()['accountId']}                         ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorTypeName']}  ${name}
    Should Be Equal As Strings    ${resp.json()['vendorId']}                          ${vendorId}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['phoneNumbers'][0]['number']}    ${vendor_ph}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['phoneNumbers'][1]['number']}    ${vendor_ph2}

    Should Be Equal As Strings    ${resp.json()['contactInfo']['emails'][0]}    ${emails[0]}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['address']}      ${address}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['state']}        ${state}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['pincode']}      ${pin}
    Should Be Equal As Strings    ${resp.json()['vendorUid']}                   ${vendor_uid11}
    Should Be Equal As Strings    ${resp.json()['categoryEncId']}                         ${category_id1}
    Should Be Equal As Strings    ${resp.json()['encId']}                              ${vendor_uid1}

    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['bankaccountNo']}    ${bank_accno1}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['ifscCode']}         ${bankIfsc1}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['bankName']}         ${bankName1}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['upiId']}            ${upiId}

    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['branchName']}    ${branchName}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['pancardNo']}     ${pan}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['gstNumber']}     ${gstin}

    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['preferredPaymentMode'][0]}    ${preferredPaymentMode[0]}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['lastPaymentModeUsed']}        ${jaldeePaymentmode[0]}

JD-TC-GetEncById-14

    [Documentation]    Try to Update vendor upiId  and then get encbyid..

    ${resp}=                      Encrypted Provider Login         ${PUSERNAME207}    ${PASSWORD}
    Log                           ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${bank_accno1}=    db.Generate_random_value    size=11    chars=${digits} 

    ${bankIfsc1}     Random Number        digits=5 
    ${bankIfsc1}=    Evaluate             f'{${bankIfsc1}:0>7d}'
    Log              ${bankIfsc1}
    ${bankName1}     FakerLibrary.name
    ${upiId1}        FakerLibrary.name


    ${preferredPaymentMode}=    Create List          ${jaldeePaymentmode[0]}
    ${bankInfo}=                Create Dictionary    bankaccountNo=${bank_accno1}    ifscCode=${bankIfsc1}    bankName=${bankName1}    upiId=${upiId1}    branchName=${branchName}    pancardNo=${pan}    gstNumber=${gstin}    preferredPaymentMode=${preferredPaymentMode}    lastPaymentModeUsed=${jaldeePaymentmode[0]}
    ${bankInfo}=                Create List          ${bankInfo}                     
    ${pin1}=                    FakerLibrary.city

    # ${vendor_ph2}=          Evaluate                  ${PUSERNAME}+1235246
    ${emails}=            Create List    ${email1}    
    Set Suite Variable    ${emails}

    ${resp}=                      Update Vendor          ${vendor_uid1}    ${category_id1}    ${vendorId}    ${vender_name}    ${contactPersonName}    ${address}    ${state}    ${pin}    ${vendor_phno1}    ${emails}    bankInfo=${bankInfo}    
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=                      Get vendor by encId                                   ${vendor_uid1}
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}                                 200
    Should Be Equal As Strings    ${resp.json()['contactPersonName']}                 ${contactPersonName}
    Should Be Equal As Strings    ${resp.json()['vendorName']}                        ${vender_name}
    Should Be Equal As Strings    ${resp.json()['id']}                                ${vendor_id1}
    Should Be Equal As Strings    ${resp.json()['accountId']}                         ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorTypeName']}  ${name}
    Should Be Equal As Strings    ${resp.json()['vendorId']}                          ${vendorId}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['phoneNumbers'][0]['number']}    ${vendor_ph}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['phoneNumbers'][1]['number']}    ${vendor_ph2}

    Should Be Equal As Strings    ${resp.json()['contactInfo']['emails'][0]}    ${emails[0]}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['address']}      ${address}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['state']}        ${state}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['pincode']}      ${pin}
    Should Be Equal As Strings    ${resp.json()['vendorUid']}                   ${vendor_uid11}
    Should Be Equal As Strings    ${resp.json()['categoryEncId']}                         ${category_id1}
    Should Be Equal As Strings    ${resp.json()['encId']}                              ${vendor_uid1}

    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['bankaccountNo']}    ${bank_accno1}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['ifscCode']}         ${bankIfsc1}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['bankName']}         ${bankName1}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['upiId']}            ${upiId1}

    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['branchName']}    ${branchName}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['pancardNo']}     ${pan}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['gstNumber']}     ${gstin}

    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['preferredPaymentMode'][0]}    ${preferredPaymentMode[0]}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['lastPaymentModeUsed']}        ${jaldeePaymentmode[0]}

JD-TC-GetEncById-15

    [Documentation]    Try to Update vendor branchName and then get encbyid..

    ${resp}=                      Encrypted Provider Login         ${PUSERNAME207}    ${PASSWORD}
    Log                           ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${bank_accno1}=    db.Generate_random_value    size=11    chars=${digits} 

    ${bankIfsc1}       Random Number        digits=5 
    ${bankIfsc1}=      Evaluate             f'{${bankIfsc1}:0>7d}'
    Log                ${bankIfsc1}
    ${bankName1}       FakerLibrary.name
    ${upiId1}          FakerLibrary.name
    ${branchName1}=    FakerLibrary.name


    ${preferredPaymentMode}=    Create List          ${jaldeePaymentmode[0]}
    ${bankInfo}=                Create Dictionary    bankaccountNo=${bank_accno1}    ifscCode=${bankIfsc1}    bankName=${bankName1}    upiId=${upiId1}    branchName=${branchName1}    pancardNo=${pan}    gstNumber=${gstin}    preferredPaymentMode=${preferredPaymentMode}    lastPaymentModeUsed=${jaldeePaymentmode[0]}
    ${bankInfo}=                Create List          ${bankInfo}                     
    ${pin1}=                    FakerLibrary.city

    # ${vendor_ph2}=          Evaluate                  ${PUSERNAME}+1235246
    ${emails}=            Create List    ${email1}    
    Set Suite Variable    ${emails}

    ${resp}=                      Update Vendor          ${vendor_uid1}    ${category_id1}    ${vendorId}    ${vender_name}    ${contactPersonName}    ${address}    ${state}    ${pin}    ${vendor_phno1}    ${emails}    bankInfo=${bankInfo}    
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=                      Get vendor by encId                                   ${vendor_uid1}
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}                                 200
    Should Be Equal As Strings    ${resp.json()['contactPersonName']}                 ${contactPersonName}
    Should Be Equal As Strings    ${resp.json()['vendorName']}                        ${vender_name}
    Should Be Equal As Strings    ${resp.json()['id']}                                ${vendor_id1}
    Should Be Equal As Strings    ${resp.json()['accountId']}                         ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorTypeName']}  ${name}
    Should Be Equal As Strings    ${resp.json()['vendorId']}                          ${vendorId}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['phoneNumbers'][0]['number']}    ${vendor_ph}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['phoneNumbers'][1]['number']}    ${vendor_ph2}

    Should Be Equal As Strings    ${resp.json()['contactInfo']['emails'][0]}    ${emails[0]}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['address']}      ${address}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['state']}        ${state}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['pincode']}      ${pin}
    Should Be Equal As Strings    ${resp.json()['vendorUid']}                   ${vendor_uid11}
    Should Be Equal As Strings    ${resp.json()['categoryEncId']}                         ${category_id1}
    Should Be Equal As Strings    ${resp.json()['encId']}                              ${vendor_uid1}

    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['bankaccountNo']}    ${bank_accno1}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['ifscCode']}         ${bankIfsc1}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['bankName']}         ${bankName1}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['upiId']}            ${upiId1}

    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['branchName']}    ${branchName1}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['pancardNo']}     ${pan}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['gstNumber']}     ${gstin}

    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['preferredPaymentMode'][0]}    ${preferredPaymentMode[0]}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['lastPaymentModeUsed']}        ${jaldeePaymentmode[0]}

JD-TC-GetEncById-16

    [Documentation]    Try to Update vendor pancardNo and then get encbyid..

    ${resp}=                      Encrypted Provider Login         ${PUSERNAME207}    ${PASSWORD}
    Log                           ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${bank_accno1}=    db.Generate_random_value    size=11    chars=${digits} 

    ${bankIfsc1}       Random Number        digits=5 
    ${bankIfsc1}=      Evaluate             f'{${bankIfsc1}:0>7d}'
    Log                ${bankIfsc1}
    ${bankName1}       FakerLibrary.name
    ${upiId1}          FakerLibrary.name
    ${branchName1}=    FakerLibrary.name
    ${pan}             Random Number        digits=5 
    ${pan1}=           Evaluate             f'{${pan}:0>5d}'

    ${preferredPaymentMode}=    Create List          ${jaldeePaymentmode[0]}
    ${bankInfo}=                Create Dictionary    bankaccountNo=${bank_accno1}    ifscCode=${bankIfsc1}    bankName=${bankName1}    upiId=${upiId1}    branchName=${branchName1}    pancardNo=${pan1}    gstNumber=${gstin}    preferredPaymentMode=${preferredPaymentMode}    lastPaymentModeUsed=${jaldeePaymentmode[0]}
    ${bankInfo}=                Create List          ${bankInfo}                     
    ${pin1}=                    FakerLibrary.city

    # ${vendor_ph2}=          Evaluate                  ${PUSERNAME}+1235246
    ${emails}=            Create List    ${email1}    
    Set Suite Variable    ${emails}

    ${resp}=                      Update Vendor          ${vendor_uid1}    ${category_id1}    ${vendorId}    ${vender_name}    ${contactPersonName}    ${address}    ${state}    ${pin}    ${vendor_phno1}    ${emails}    bankInfo=${bankInfo}    
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=                      Get vendor by encId                                  ${vendor_uid1}
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}                                 200
    Should Be Equal As Strings    ${resp.json()['contactPersonName']}                 ${contactPersonName}
    Should Be Equal As Strings    ${resp.json()['vendorName']}                        ${vender_name}
    Should Be Equal As Strings    ${resp.json()['id']}                                ${vendor_id1}
    Should Be Equal As Strings    ${resp.json()['accountId']}                         ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorTypeName']}  ${name}
    Should Be Equal As Strings    ${resp.json()['vendorId']}                          ${vendorId}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['phoneNumbers'][0]['number']}    ${vendor_ph}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['phoneNumbers'][1]['number']}    ${vendor_ph2}

    Should Be Equal As Strings    ${resp.json()['contactInfo']['emails'][0]}    ${emails[0]}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['address']}      ${address}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['state']}        ${state}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['pincode']}      ${pin}
    Should Be Equal As Strings    ${resp.json()['vendorUid']}                   ${vendor_uid11}
    Should Be Equal As Strings    ${resp.json()['categoryEncId']}                         ${category_id1}
    Should Be Equal As Strings    ${resp.json()['encId']}                              ${vendor_uid1}

    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['bankaccountNo']}    ${bank_accno1}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['ifscCode']}         ${bankIfsc1}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['bankName']}         ${bankName1}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['upiId']}            ${upiId1}

    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['branchName']}    ${branchName1}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['pancardNo']}     ${pan1}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['gstNumber']}     ${gstin}

    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['preferredPaymentMode'][0]}    ${preferredPaymentMode[0]}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['lastPaymentModeUsed']}        ${jaldeePaymentmode[0]}

JD-TC-GetEncById-17

    [Documentation]    Try to Update vendor gstNumber  and then get encbyid..

    ${resp}=                      Encrypted Provider Login         ${PUSERNAME207}    ${PASSWORD}
    Log                           ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${bank_accno1}=    db.Generate_random_value    size=11    chars=${digits} 

    ${bankIfsc1}       Random Number        digits=5 
    ${bankIfsc1}=      Evaluate             f'{${bankIfsc1}:0>7d}'
    Log                ${bankIfsc1}
    ${bankName1}       FakerLibrary.name
    ${upiId1}          FakerLibrary.name
    ${branchName1}=    FakerLibrary.name
    ${pan}             Random Number        digits=5 
    ${pan1}=           Evaluate             f'{${pan}:0>5d}'

    ${gstin}      Random Number    digits=5 
    ${gstin1}=    Evaluate         f'{${gstin}:0>8d}'

    ${preferredPaymentMode}=    Create List          ${jaldeePaymentmode[0]}
    ${bankInfo}=                Create Dictionary    bankaccountNo=${bank_accno1}    ifscCode=${bankIfsc1}    bankName=${bankName1}    upiId=${upiId1}    branchName=${branchName1}    pancardNo=${pan1}    gstNumber=${gstin1}    preferredPaymentMode=${preferredPaymentMode}    lastPaymentModeUsed=${jaldeePaymentmode[0]}
    ${bankInfo}=                Create List          ${bankInfo}                     
    ${pin1}=                    FakerLibrary.city

    # ${vendor_ph2}=          Evaluate                  ${PUSERNAME}+1235246
    ${emails}=            Create List    ${email1}    
    Set Suite Variable    ${emails}

    ${resp}=                      Update Vendor          ${vendor_uid1}    ${category_id1}    ${vendorId}    ${vender_name}    ${contactPersonName}    ${address}    ${state}    ${pin}    ${vendor_phno1}    ${emails}    bankInfo=${bankInfo}    
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=                      Get vendor by encId                                   ${vendor_uid1}
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}                                 200
    Should Be Equal As Strings    ${resp.json()['contactPersonName']}                 ${contactPersonName}
    Should Be Equal As Strings    ${resp.json()['vendorName']}                        ${vender_name}
    Should Be Equal As Strings    ${resp.json()['id']}                                ${vendor_id1}
    Should Be Equal As Strings    ${resp.json()['accountId']}                         ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorTypeName']}  ${name}
    Should Be Equal As Strings    ${resp.json()['vendorId']}                          ${vendorId}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['phoneNumbers'][0]['number']}    ${vendor_ph}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['phoneNumbers'][1]['number']}    ${vendor_ph2}

    Should Be Equal As Strings    ${resp.json()['contactInfo']['emails'][0]}    ${emails[0]}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['address']}      ${address}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['state']}        ${state}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['pincode']}      ${pin}
    Should Be Equal As Strings    ${resp.json()['vendorUid']}                   ${vendor_uid11}
    Should Be Equal As Strings    ${resp.json()['categoryEncId']}                         ${category_id1}
    Should Be Equal As Strings    ${resp.json()['encId']}                              ${vendor_uid1}

    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['bankaccountNo']}    ${bank_accno1}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['ifscCode']}         ${bankIfsc1}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['bankName']}         ${bankName1}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['upiId']}            ${upiId1}

    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['branchName']}    ${branchName1}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['pancardNo']}     ${pan1}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['gstNumber']}     ${gstin1}

    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['preferredPaymentMode'][0]}    ${preferredPaymentMode[0]}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['lastPaymentModeUsed']}        ${jaldeePaymentmode[0]}

JD-TC-GetEncById-18

    [Documentation]    Try to Update vendor preferredPaymentMode  and then get encbyid..

    ${resp}=                      Encrypted Provider Login         ${PUSERNAME207}    ${PASSWORD}
    Log                           ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${bank_accno1}=    db.Generate_random_value    size=11    chars=${digits} 

    ${bankIfsc1}       Random Number        digits=5 
    ${bankIfsc1}=      Evaluate             f'{${bankIfsc1}:0>7d}'
    Log                ${bankIfsc1}
    ${bankName1}       FakerLibrary.name
    ${upiId1}          FakerLibrary.name
    ${branchName1}=    FakerLibrary.name
    ${pan}             Random Number        digits=5 
    ${pan1}=           Evaluate             f'{${pan}:0>5d}'

    ${gstin}      Random Number    digits=5 
    ${gstin1}=    Evaluate         f'{${gstin}:0>8d}'

    ${preferredPaymentMode}=    Create List          ${jaldeePaymentmode[1]}
    ${bankInfo}=                Create Dictionary    bankaccountNo=${bank_accno1}    ifscCode=${bankIfsc1}    bankName=${bankName1}    upiId=${upiId1}    branchName=${branchName1}    pancardNo=${pan1}    gstNumber=${gstin1}    preferredPaymentMode=${preferredPaymentMode}    lastPaymentModeUsed=${jaldeePaymentmode[0]}
    ${bankInfo}=                Create List          ${bankInfo}                     
    ${pin1}=                    FakerLibrary.city

    # ${vendor_ph2}=          Evaluate                  ${PUSERNAME}+1235246
    ${emails}=            Create List    ${email1}    
    Set Suite Variable    ${emails}

    ${resp}=                      Update Vendor          ${vendor_uid1}    ${category_id1}    ${vendorId}    ${vender_name}    ${contactPersonName}    ${address}    ${state}    ${pin}    ${vendor_phno1}    ${emails}    bankInfo=${bankInfo}    
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=                      Get vendor by encId                                  ${vendor_uid1}
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}                                 200
    Should Be Equal As Strings    ${resp.json()['contactPersonName']}                 ${contactPersonName}
    Should Be Equal As Strings    ${resp.json()['vendorName']}                        ${vender_name}
    Should Be Equal As Strings    ${resp.json()['id']}                                ${vendor_id1}
    Should Be Equal As Strings    ${resp.json()['accountId']}                         ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorTypeName']}  ${name}
    Should Be Equal As Strings    ${resp.json()['vendorId']}                          ${vendorId}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['phoneNumbers'][0]['number']}    ${vendor_ph}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['phoneNumbers'][1]['number']}    ${vendor_ph2}

    Should Be Equal As Strings    ${resp.json()['contactInfo']['emails'][0]}    ${emails[0]}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['address']}      ${address}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['state']}        ${state}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['pincode']}      ${pin}
    Should Be Equal As Strings    ${resp.json()['vendorUid']}                   ${vendor_uid11}
    Should Be Equal As Strings    ${resp.json()['categoryEncId']}                         ${category_id1}
    Should Be Equal As Strings    ${resp.json()['encId']}                              ${vendor_uid1}

    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['bankaccountNo']}    ${bank_accno1}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['ifscCode']}         ${bankIfsc1}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['bankName']}         ${bankName1}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['upiId']}            ${upiId1}

    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['branchName']}    ${branchName1}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['pancardNo']}     ${pan1}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['gstNumber']}     ${gstin1}

    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['preferredPaymentMode'][0]}    ${preferredPaymentMode[0]}
    Should Be Equal As Strings    ${resp.json()['bankInfo'][0]['lastPaymentModeUsed']}        ${jaldeePaymentmode[0]}




JD-TC-GetEncById-UH1

    [Documentation]     get encbyid without Login.


    ${resp}=                      Get vendor by encId                                  ${vendor_uid1}
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}         ${SESSION_EXPIRED}

JD-TC-GetEncById-UH2

    [Documentation]    get encbyid  using another Encrypted Provider Login .

    ${resp}=                      Encrypted Provider Login         ${PUSERNAME5}    ${PASSWORD}
    Log                           ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # Should Be Equal As Strings    ${resp.status_code}                 422

    ${resp}=                      Get vendor by encId                                  ${vendor_uid1}
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}         ${INVALID_VENDOR}    



