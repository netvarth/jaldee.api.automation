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
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf
${jpgfile2}      /ebs/TDD/small.jpg
${gif}      /ebs/TDD/sample.gif
${xlsx}      /ebs/TDD/qnr.xlsx

${order}    0
${fileSize}  0.00458
${service_duration}     30
${service_duration1}     10
${self}         0
@{status1}    New     Pending    Assigned     Approved    Rejected
@{New_status}         status1  Proceed     Unassign    Block     Delete    Remove
${DisplayName1}   item1_DisplayName





*** Test Cases ***
JD-TC-Update cash payment- finance invoice level-1

    [Documentation]  provider takes waitlist and accept payment thenupdate cash 
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME195}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_customer   ${PUSERNAME195}

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
    Set Suite Variable   ${category_id}   ${resp.json()}
    
    ${name}=   FakerLibrary.word
    ${resp}=  Create Category   ${name}  ${categoryType[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id1}   ${resp.json()}

    ${name1}=   FakerLibrary.word
    Set Suite Variable   ${name1}
    ${resp}=  Create Category   ${name1}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id2}   ${resp.json()}

    ${resp}=  Get Category By Id   ${category_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}          ${name}
    Should Be Equal As Strings  ${resp.json()['categoryType']}  ${categoryType[1]}
    Should Be Equal As Strings  ${resp.json()['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()['status']}        ${toggle[0]}

    ${vender_name}=   FakerLibrary.firstname
    ${contactPersonName}=   FakerLibrary.lastname
    ${owner_name}=   FakerLibrary.lastname
    ${vendorId}=   FakerLibrary.word
    ${PO_Number}    Generate random string    5    123456789
    ${vendor_phno}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${vendor_phno}=  Create Dictionary  countryCode=${countryCodes[0]}   number=${vendor_phno}
    Set Test Variable  ${email}  ${vender_name}.${test_mail}
    ${address}=  FakerLibrary.city
    Set Suite Variable  ${address}
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
    
    ${resp}=  Create Vendor  ${category_id}  ${vendorId}  ${vender_name}   ${contactPersonName}    ${address}    ${state}    ${pin}   ${vendor_phno}   ${email}     bankInfo=${bankInfo}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${vendor_uid1}   ${resp.json()['encId']}
    Set Suite Variable   ${vendor_id1}   ${resp.json()['id']}

    ${resp}=  Get vendor by encId   ${vendor_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${vendor_id1}
    Should Be Equal As Strings  ${resp.json()['accountId']}  ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorType']}  ${category_id}

    ${resp1}=  AddCustomer  ${CUSERNAME11}
    Log  ${resp1.json()}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Suite Variable   ${pcid18}   ${resp1.json()}

    ${providerConsumerIdList}=  Create List  ${pcid18}
    Set Suite Variable  ${providerConsumerIdList}   


    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${invoiceLabel}=   FakerLibrary.word
    ${invoiceDate}=   db.get_date
    # ${invoiceDate}=   Get Current Date    result_format=%Y/%m/%d
    ${invoiceId}=   FakerLibrary.word

    ${item1}=     FakerLibrary.word
    ${itemCode1}=     FakerLibrary.word
    ${price1}=     Random Int   min=400   max=500
    ${price}=  Convert To Number  ${price1}  1
    Set Suite Variable  ${price} 
    ${resp}=  Create Sample Item   ${DisplayName1}   ${item1}  ${itemCode1}  ${price}  ${bool[1]} 
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${itemId}  ${resp.json()}

    ${resp}=   Get Item By Id  ${itemId}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${promotionalPrice}   ${resp.json()['promotionalPrice']}


    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    ${itemList}=  Create Dictionary  itemId=${itemId}   quantity=${quantity}   price=${promotionalPrice}
    # ${itemList}=    Create List    ${itemList}

    ${resp}=  Create Finance Status   ${New_status[3]}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${status_id1}   ${resp.json()}

    ${SERVICE1}=    FakerLibrary.word
    Set Suite Variable  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${serviceprice}=   Random Int  min=10  max=15
    ${serviceprice}=  Convert To Number  ${serviceprice}  1

    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${service_duration}   ${status[0]}    ${btype}    ${bool[1]}    ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid1}  ${resp.json()}

    ${serviceList}=  Create Dictionary  serviceId=${sid1}   quantity=${quantity}  price=${serviceprice}
    ${serviceList}=    Create List    ${serviceList}


    ${itemName}=    FakerLibrary.word
    Set Suite Variable  ${itemName}
    ${price}=   Random Int  min=10  max=15
    ${price}=  Convert To Number  ${price}  1
    ${adhocItemList}=  Create Dictionary  itemName=${itemName}   quantity=${quantity}   price=${price}
    ${adhocItemList}=    Create List    ${adhocItemList}

    
    ${resp}=  Create Invoice   ${category_id2}    ${invoiceDate}   ${invoiceLabel}   ${address}   ${vendor_uid1}   ${invoiceId}    ${providerConsumerIdList}    ${itemList}  invoiceStatus=${status_id1}    serviceList=${serviceList}   adhocItemList=${adhocItemList}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoice_id}   ${resp.json()['idList'][0]}
    Set Suite Variable   ${invoice_uid}   ${resp.json()['uidList'][0]}    

    ${resp1}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()['accountId']}  ${account_id1}
    Should Be Equal As Strings  ${resp1.json()['invoiceCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp1.json()['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp1.json()['invoiceDate']}  ${invoiceDate}
    Should Be Equal As Strings  ${resp1.json()['invoiceLabel']}  ${invoiceLabel}
    Should Be Equal As Strings  ${resp1.json()['billedTo']}  ${address}
    Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['serviceId']}  ${sid1}
    Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp1.json()['adhocItemList'][0]['itemName']}  ${itemName}
    Should Be Equal As Strings  ${resp1.json()['adhocItemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp1.json()['adhocItemList'][0]['price']}  ${price}

    ${adhoc_amt}=    Evaluate  ${price}*${quantity}
    ${service_amt}=    Evaluate  ${serviceprice}*${quantity}
    ${item_amt}=    Evaluate  ${promotionalPrice}*${quantity}

    ${discAmt}=    Evaluate  ${adhoc_amt}+${service_amt}+${item_amt}

    ${balance}=    evaluate    ${discAmt}-10
    ${balance}=  Convert To Number  ${balance}  2

    ${note}=    FakerLibrary.word
    ${resp}=  Make Payment By Cash For Invoice   ${invoice_uid}  ${payment_modes[0]}  10  ${note}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Payment By UUId  ${invoice_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${paymentRefId}  ${resp.json()[0]['paymentRefId']} 


    ${resp}=  Update cash payment- finance invoice level   ${invoice_uid}  ${payment_modes[0]}  25  ${note}  ${paymentRefId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${amountdue}=  Evaluate  ${discAmt}-25
    ${resp1}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()['amountPaid']}  25.0
    Should Be Equal As Strings  ${resp1.json()['amountDue']}  ${amountdue}
    # Should Be Equal As Strings  ${resp.json()['netTotal']}  ${servicetotalAmount1}


    # ${resp1}=  Get Invoice By Id  ${invoice_uid}
    # Log  ${resp1.content}
    # Should Be Equal As Strings  ${resp1.status_code}  200
    # Should Be Equal As Strings  ${resp1.json()['amountDue']}  ${balance}
    # Should Be Equal As Strings  ${resp1.json()['amountPaid']}  10.0

JD-TC-Update cash payment- finance invoice level-2

    [Documentation]  Update cash payment with different amount.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME195}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${note}=    FakerLibrary.word
    ${resp}=  Update cash payment- finance invoice level   ${invoice_uid}  ${payment_modes[0]}  30  ${note}  ${paymentRefId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Update cash payment- finance invoice level-UH1

    [Documentation]   Update cash payment- finance invoice level with invalid invoice id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME195}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${note}=    FakerLibrary.word
    ${invoice}=    FakerLibrary.RandomNumber
    ${resp}=  Update cash payment- finance invoice level   ${invoice}  ${payment_modes[0]}  30  ${note}  ${paymentRefId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${RECORD_NOT_FOUND}" 



JD-TC-Update cash payment- finance invoice level-UH2

    [Documentation]  Make payment by cash without login
    ${note}=    FakerLibrary.word
    ${resp}=  Update cash payment- finance invoice level   ${invoice_uid}  ${payment_modes[0]}  30  ${note}  ${paymentRefId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-Update cash payment- finance invoice level-UH3

    [Documentation]  Update cash payment- finance invoice level with another provider login

    ${resp}=   Encrypted Provider Login  ${PUSERNAME204}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END


    ${note}=    FakerLibrary.word
    ${resp}=  Update cash payment- finance invoice level   ${invoice_uid}  ${payment_modes[0]}  30  ${note}  ${paymentRefId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}" 

JD-TC-Update cash payment- finance invoice level-3

    [Documentation]  Taking waitlist from consumer side and the consumer doing the prepayment - balance amount paid by provider side,then edit that amount

   

    ${PO_Number}    Generate random string    8    1235468479
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERPH2}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH2}${\n}
    Set Suite Variable   ${PUSERPH2}
    ${resp}=   Run Keywords  clear_queue  ${PUSERPH2}   AND  clear_service  ${PUSERPH2}  AND  clear_Item    ${PUSERPH2}  AND   clear_Coupon   ${PUSERPH2}   AND  clear_Discount  ${PUSERPH2}  AND  clear_appt_schedule   ${PUSERPH2}
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    Set Test Variable   ${licid}
    
    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.content}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    ${d1}=  Random Int   min=0  max=${dlen-1}
    Set Test Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
    ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
    ${sdom}=  Random Int   min=0  max=${sdlen-1}
    Set Test Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ['Male', 'Female']
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERPH2}  ${licid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Activation  ${PUSERPH2}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.content}    "true"
    
    ${resp}=  Account Set Credential  ${PUSERPH2}  ${PASSWORD}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH2}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid2}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  
    @{Views}=  Create List  self  all  customersOnly
    ${ph1}=  Evaluate  ${PUSERPH2}+1000000000
    ${ph2}=  Evaluate  ${PUSERPH2}+2000000000
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}025.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ['True','False']
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    Set Suite Variable   ${eTime}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}  
    
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
    Log  ${fields.content}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    Set Test Variable  ${email_id}  ${P_Email}${PUSERPH2}.${test_mail}

    ${resp}=  Update Email   ${pid2}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    # ------------- Get general details and settings of the provider and update all needed settings
    
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid2}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Verify Response  ${resp}  onlineCheckIns=${bool[1]}

    ${resp}=  Enable Waitlist
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp1}=   Run Keyword If  ${resp.json()['onlinePresence']}==${bool[0]}   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=  Get Account Payment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END
    
    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

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
    Set Suite Variable  ${accountId2}  ${resp.json()['accountId']}    
    

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    ${p1_lid}=  Create Sample Location
    ${resp}=  Get Locations
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_lid}  ${resp.json()[0]['id']} 

    ${min_pre1}=   Random Int   min=40   max=50
    ${Tot}=   Random Int   min=100   max=300
    ${min_pre1}=   Convert To Integer  ${min_pre1}  
    Set Suite Variable   ${min_pre1}
    # ${pre_float}=  twodigitfloat  ${min_pre}
    ${Tot11}=   Convert To Integer  ${Tot}   
    Set Suite Variable   ${Tot2}   ${Tot11}

    ${P1SERVICE11}=    FakerLibrary.word
    Set Suite Variable   ${P1SERVICE11}
    ${desc}=   FakerLibrary.sentence
    ${maxBookingsAllowed}=   Random Int   min=2   max=5
    ${resp}=  Create Service  ${P1SERVICE11}  ${desc}   ${service_duration1}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot2}  ${bool[1]}  ${bool[0]}    maxBookingsAllowed=${maxBookingsAllowed}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_sid11}  ${resp.json()}

    ${resp}=  Auto Invoice Generation For Service   ${p1_sid11}    ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${p1_sid11}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[1]}



    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${sTime}=  add_timezone_time  ${tz}  2  00  
    ${eTime}=  add_timezone_time  ${tz}  2  15  
    ${parallel}=   Random Int  min=1   max=1
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p1_lid}  ${p1_sid11}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_qid1}  ${resp.json()}


    ${resp}=   Get Category With Filter  categoryType-eq=${categoryType[3]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



    ${firstName}=  FakerLibrary.name
    Set Suite Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Suite Variable    ${lastName}
    ${primaryMobileNo}    Generate random string    10    123456789
    ${primaryMobileNo1}    Convert To Integer  ${primaryMobileNo}
    Set Suite Variable    ${primaryMobileNo1}
    ${email}=    FakerLibrary.Email
    Set Suite Variable    ${email}

    ${resp}=    Send Otp For Login    ${primaryMobileNo1}    ${accountId2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo1}   12
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Customer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${primaryMobileNo1}     ${accountId2}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo1}    ${accountId2}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid1}    ${resp.json()['providerConsumer']}


    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Output/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Add To Waitlist Consumers  ${pid2}  ${p1_qid1}  ${DAY}  ${p1_sid11}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid3}  ${wid[0]} 
    

    ${balamount}=  Evaluate  ${Tot2}-${min_pre1}
    ${balamount}=   Convert To Integer  ${balamount}  

    sleep   02s

    ${resp}=  Get consumer Waitlist By Id  ${cwid3}  ${pid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}


    sleep   02s

    ${resp}=  Make payment Consumer Mock  ${pid2}  ${min_pre1}  ${purpose[0]}  ${cwid3}  ${p1_sid11}  ${bool[0]}   ${bool[1]}  ${None}
    Log  ${resp.json()}
    # ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre}  ${purpose[0]}  ${cwid}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid1}
    # Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

    sleep   02s

    ${resp}=  Get Payment Details  account-eq=${pid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[1]['amount']}   ${min_pre1}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[1]['accountId']}   ${pid2}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${bal_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid2}

    ${resp}=  Encrypted Provider Login  ${PUSERPH2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp1}=  Get consumer Waitlist Bill Details   ${cwid3}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    ${resp}=   Get Service By Id  ${p1_sid11}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[1]}

    sleep   01s
    ${resp}=  Get Bookings Invoices  ${cwid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

   ${service_response_price}=  Convert To Integer  ${resp.json()[0]['serviceList'][0]['price']} 
   ${service_response_netRate}=  Convert To Integer  ${resp.json()[0]['serviceList'][0]['netRate']} 
   ${response_amountPaid}=  Convert To Integer  ${resp.json()[0]['amountPaid']}
   ${response_amountDue}=  Convert To Integer  ${resp.json()[0]['amountDue']}
   ${response_amountTotal}=  Convert To Integer  ${resp.json()[0]['amountTotal']}
   ${response_defaultCurrencyAmount}=  Convert To Integer  ${resp.json()[0]['defaultCurrencyAmount']}
   ${response_netTaxAmount}=  Convert To Integer  ${resp.json()[0]['netTaxAmount']}
   ${response_netTotal}=  Convert To Integer  ${resp.json()[0]['netTotal']}
   ${response_netRate}=  Convert To Integer  ${resp.json()[0]['netRate']}
   ${response_taxableTotal}=  Convert To Integer  ${resp.json()[0]['taxableTotal']}

    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceId']}  ${p1_sid11}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceName']}  ${P1SERVICE11}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${service_response_price}   ${Tot2}
    Should Be Equal As Strings  ${service_response_netRate}  ${Tot2}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['ynwUuid']}  ${cwid3}
    Should Be Equal As Strings   ${response_amountPaid}   ${min_pre1}
    Should Be Equal As Strings  ${response_amountDue}  ${balamount}
    Should Be Equal As Strings  ${resp.json()[0]['taxPercentage']}  0.0
    Should Be Equal As Strings   ${response_defaultCurrencyAmount}  ${Tot2}
    Should Be Equal As Strings  ${response_netTaxAmount}  0
    Should Be Equal As Strings  ${response_netTotal}  ${Tot2}
    Should Be Equal As Strings  ${response_netRate}  ${Tot2}
    Should Be Equal As Strings   ${response_taxableTotal}  0
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${cwid3}
    Set Suite Variable  ${invoice_wtlistonline_uid2}  ${resp.json()[0]['invoiceUid']}
    Should Be Equal As Strings  ${resp.json()[0]['billPaymentStatus']}  ${paymentStatus[1]}
    Should Be Equal As Strings   ${response_amountTotal}  ${Tot2}

    ${note}=    FakerLibrary.word
    ${resp}=  Make Payment By Cash For Invoice   ${invoice_wtlistonline_uid2}  ${payment_modes[0]}  ${balamount}  ${note}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Payment By UUId  ${invoice_wtlistonline_uid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${paymentRefId}  ${resp.json()[0]['paymentRefId']} 


    ${resp}=  Update cash payment- finance invoice level   ${invoice_wtlistonline_uid2}  ${payment_modes[0]}  100  ${note}  ${paymentRefId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${amountdue}=  Evaluate  ${balamount}-100

    ${tamountPaid}=  Evaluate  ${min_pre1}+100
    ${resp1}=  Get Invoice By Id  ${invoice_wtlistonline_uid2}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    ${response_amount}=  Convert To Integer  ${resp1.json()['amountDue']} 
    ${response_amountpaids}=  Convert To Integer  ${resp1.json()['amountPaid']}
    Should Be Equal As Strings  ${response_amountpaids}  ${tamountPaid}
    Should Be Equal As Strings  ${response_amount}  ${amountdue}


