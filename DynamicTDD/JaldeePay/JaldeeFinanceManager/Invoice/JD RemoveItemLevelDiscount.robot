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
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/hl_musers.py

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
@{emptylist}

@{status1}    New     Pending    Assigned     Approved    Rejected
@{New_status}    Proceed     Unassign    Block     Delete    Remove
${DisplayName1}   item1_DisplayName

***Keywords***


Get Billable Subdomain
    [Arguments]   ${domain}  ${jsondata}  ${posval}  
    ${length}=  Get Length  ${jsondata.json()[${posval}]['subDomains']}
    FOR  ${pos}  IN RANGE  ${length}
            Set Suite Variable  ${subdomain}  ${jsondata.json()[${posval}]['subDomains'][${pos}]['subDomain']}
            ${resp}=   Get Sub Domain Settings    ${domain}    ${subdomain}
            Should Be Equal As Strings    ${resp.status_code}    200
            Exit For Loop IF  '${resp.json()['serviceBillable']}' == '${bool[1]}'
    END
    RETURN  ${subdomain}  ${resp.json()['serviceBillable']}



Get Non Billable Subdomain
    [Arguments]   ${domain}  ${jsondata}  ${posval}  
    ${length}=  Get Length  ${jsondata.json()[${posval}]['subDomains']}
    FOR  ${pos}  IN RANGE  ${length}
            Set Test Variable  ${subdomain}  ${jsondata.json()[${posval}]['subDomains'][${pos}]['subDomain']}
            ${resp}=   Get Sub Domain Settings    ${domain}    ${subdomain}
            Should Be Equal As Strings    ${resp.status_code}    200
            Exit For Loop IF  '${resp.json()['serviceBillable']}' == '${bool[0]}'
    END
    RETURN  ${subdomain}  ${resp.json()['serviceBillable']}



*** Test Cases ***

JD-TC-Remove Item Level Discount-1

    [Documentation]  Remove Item Level Discount where account is taxable(service non taxable and item is taxable).


    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+3381538
    Set Suite Variable   ${PUSERPH0}
    
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
   FOR  ${pos}  IN RANGE  ${dlen}  
        Set Suite Variable  ${d1}  ${domresp.json()[${pos}]['domain']}
        ${sd1}  ${check}=  Get Billable Subdomain  ${d1}  ${domresp}  ${pos}  
        Set Suite Variable   ${sd1}
        Exit For Loop IF     '${check}' == '${bool[1]}'
    END
    Log  ${d1}
    Log  ${sd1}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}=    Random Element    ${Genderlist}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${PUSERPH0}  ${licid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Activation  ${PUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  "${resp.json()}"    "true"
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}

    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${result}=  Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment
    Log   ${result.json()}
    Should Be Equal As Strings  ${result.status_code}  200
    ${resp}=   Get Accountsettings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appointment']}   ${bool[1]}
    

    ${accId}=  get_acc_id  ${PUSERPH0}
    Set Suite Variable  ${accId}

    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph1}=  Evaluate  ${PUSERPH0}+1000000000
    ${ph2}=  Evaluate  ${PUSERPH0}+2000000000
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${city}=   get_place
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${companySuffix}=  FakerLibrary.companySuffix
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  add_time  0  15
    Set Suite Variable   ${sTime}
    ${eTime}=  add_time   0  45
    Set Suite Variable   ${eTime}
    ${resp}=  Update Business Profile With Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

        ${gstper}=  Random Element  ${gstpercentage}
        ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
        ${resp}=  Update Tax Percentage  ${gstper}  ${GST_num}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Enable Tax
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Get Tax Percentage
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Test Variable  ${tax_per}  ${resp.json()['taxPercentage']}


    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}

    ${fields}=   Get subDomain level Fields  ${d1}  ${sd1}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${d1}  ${sd1}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}   

    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200




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



    
    ${resp}=  Create Sample Location  
    Set Suite Variable    ${lid}    ${resp}  

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    
    ${name}=   FakerLibrary.name
    ${resp}=  Create Category   ${name}  ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id}   ${resp.json()}


    ${name1}=   FakerLibrary.word
    Set Suite Variable   ${name1}
    ${resp}=  Create Category   ${name1}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id2}   ${resp.json()}

    ${vender_name}=   FakerLibrary.firstname
    ${contactPersonName}=   FakerLibrary.lastname
    ${owner_name}=   FakerLibrary.lastname
    ${vendorId}=   FakerLibrary.word
    ${PO_Number}    Generate random string    5    123456789
    ${vendor_phno}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${vendor_phno}=  Create Dictionary  countryCode=${countryCodes[0]}   number=${vendor_phno}
    Set Test Variable  ${email}  ${vender_name}${vendor_phno}.${test_mail}
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
    Set Suite Variable   ${vendor_uid1}   ${resp.json()['uid']}
    Set Suite Variable   ${vendor_id1}   ${resp.json()['id']}

    ${resp}=  Get Vendor By Id   ${vendor_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${vendor_id1}
    Should Be Equal As Strings  ${resp.json()['accountId']}  ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorType']}  ${category_id}

    ${resp1}=  AddCustomer  ${CUSERNAME11}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Suite Variable  ${pcid18}   ${resp1.json()}


    ${providerConsumerIdList}=  Create List  ${pcid18}
    Set Suite Variable  ${providerConsumerIdList}  

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${invoiceLabel}=   FakerLibrary.word
    ${invoiceDate}=   db.get_date_by_timezone  ${tz}
    ${invoiceId}=   FakerLibrary.word


     ${SERVICE1}=    FakerLibrary.word
    Set Suite Variable  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${service_duration}   ${status[0]}    ${btype}    ${bool[1]}    ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid1}  ${resp.json()} 

    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=   Convert To Integer  ${quantity}  
    ${serviceprice}=   Random Int  min=1000  max=1500
    ${serviceprice}=   Convert To Integer  ${serviceprice}  

    ${serviceList}=  Create Dictionary  serviceId=${sid1}   quantity=${quantity}  price=${serviceprice}
    ${serviceList}=    Create List    ${serviceList}
    ${servicenetRate}=  Evaluate  ${quantity} * ${serviceprice}
    ${servicenetRate}=   Convert To Integer  ${servicenetRate}   
    Set Test Variable   ${servicenetRate}

     ${item1}=     FakerLibrary.word
    ${itemCode1}=     FakerLibrary.word
    ${price1}=     Random Int   min=400   max=500
    ${price}=   Convert To Integer  ${price1}  
    Set Suite Variable  ${price} 
    ${resp}=  Create Sample Item   ${DisplayName1}   ${item1}  ${itemCode1}  ${price}  ${bool[1]} 
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${itemId}  ${resp.json()}

    ${resp}=   Get Item By Id  ${itemId}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${promotionalPrice}   ${resp.json()['promotionalPrice']}
    ${promotionalPrice}=   Convert To Integer  ${promotionalPrice}  


    ${quantity}=   Random Int  min=1000  max=5000
    ${quantity}=   Convert To Integer  ${quantity}  
    ${itemList}=  Create Dictionary  itemId=${itemId}   quantity=${quantity}  price=${promotionalPrice}
    ${totalPrice}=  Evaluate  ${quantity} * ${promotionalPrice}
    ${totalPrice}=   Convert To Integer  ${totalPrice}   
    Set Test Variable   ${totalPrice}
    
    
    ${resp}=  Create Invoice   ${category_id2}   ${invoiceDate}   ${invoiceLabel}   ${address}   ${vendor_uid1}   ${invoiceId}    ${providerConsumerIdList}  ${itemList}  serviceList=${serviceList}   billStatus=${billStatus[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoice_uid}   ${resp.json()['uidList'][0]} 

    ${discount1}=     FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${discountprice1}=     Random Int   min=50   max=100
    ${discountprice}=   Convert To Integer  ${discountprice1}  
    Set Suite Variable   ${discountprice}
    ${resp}=   Create Discount  ${discount1}   ${desc}    ${discountprice}   ${calctype[1]}  ${disctype[0]}
    Log  ${resp.json()}
    Set Suite Variable   ${discountId}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Discounts 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${discountValue1}=     Random Int   min=50   max=100
    ${discountValue1}=   Convert To Integer  ${discountValue1}  


    ${resp}=  Apply Item Level Discount   ${invoice_uid}   ${discountId}    ${discountValue1}   ${privateNote}  ${displayNote}   ${itemId}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${netRate}=  Evaluate  ${totalPrice} - ${discountprice}
    ${netRate}=   Convert To Integer  ${netRate}  
    # ${netRate}=  Evaluate  "%.2f" % ${netRate}
    Set Test Variable   ${netRate}

        ${netTaxAmount}=  Evaluate  ${netRate}*(${tax_per}/100)
        ${netTaxAmount}=   Convert To Integer  ${netTaxAmount}   
        ${total_amt_with_tax}=  Evaluate  ${netRate}+${netTaxAmount}
        ${total_amt_with_tax}=   Convert To Integer  ${total_amt_with_tax}   
        ${netTotal}=  Evaluate  ${total_amt_with_tax}+${servicenetRate}
        ${netTotal}=   Convert To Integer  ${netTotal}   
        ${rate}=  Evaluate  ${netRate}+${servicenetRate}
        ${rate}=   Convert To Integer  ${rate}   
        ${amountTotal}=  Evaluate  ${rate}-${netTaxAmount} 
        ${amountTotal}=   Convert To Integer  ${amountTotal}   


    ${resp1}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp1.content}
    ${rate1}=    Convert To Integer  ${resp1.json()['netTotal']} 
    ${netTotal1}=    Convert To Integer  ${resp1.json()['netRate']} 
    ${totalPrice1}=    Convert To Integer  ${resp1.json()['itemList'][0]['totalPrice']}
    ${discountprice1}=    Convert To Integer  ${resp1.json()['itemList'][0]['discountTotal']}
    ${netRate1}=    Convert To Integer  ${resp1.json()['itemList'][0]['netRate']} 
    ${servicenetRate1}=    Convert To Integer  ${resp1.json()['serviceList'][0]['totalPrice']} 
    ${servicenetRate11}=    Convert To Integer  ${resp1.json()['serviceList'][0]['netRate']} 
    ${taxableTotal1}=    Convert To Integer   ${resp1.json()['taxableTotal']} 
    ${nonTaxableTotal1}=    Convert To Integer   ${resp1.json()['nonTaxableTotal']} 
    ${netTaxAmount1}=    Convert To Integer   ${resp1.json()['netTaxAmount']}
    ${temporaryTotalAmount1}=    Convert To Integer   ${resp1.json()['temporaryTotalAmount']} 
    ${amountTotal1}=    Convert To Integer   ${resp1.json()['amountTotal']}
    ${amountDue1}=    Convert To Integer   ${resp1.json()['amountDue']} 


    Should Be Equal As Strings  ${resp1.json()['itemList'][0]['discounts'][0]['id']}   ${discountId}
    Should Be Equal As Strings   ${rate1}    ${rate}
    Should Be Equal As Strings  ${netTotal1}     ${netTotal}
    Should Be Equal As Strings  ${totalPrice1}   ${totalPrice}
    Should Be Equal As Strings  ${discountprice1}   ${discountprice}
    Should Be Equal As Strings  ${netRate1}   ${netRate}
    Should Be Equal As Strings   ${servicenetRate1}  ${servicenetRate}
    Should Be Equal As Strings   ${servicenetRate11}  ${servicenetRate}
    Should Be Equal As Strings   ${taxableTotal1}  ${netRate}
    Should Be Equal As Strings   ${nonTaxableTotal1}     ${servicenetRate}
    Should Be Equal As Strings  ${netTaxAmount1}     ${netTaxAmount}
    Should Be Equal As Strings  ${temporaryTotalAmount1}     ${rate}
    # Should Be Equal As Strings  ${amountTotal1}     ${amountTotal}
    Should Be Equal As Strings  ${amountDue1}     ${netTotal}


    ${resp}=  Remove Item Level Discount   ${invoice_uid}   ${discountId}    ${discountValue1}   ${privateNote}  ${displayNote}   ${itemId}
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp.content}
 
    Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts']}  []





JD-TC-Remove Item Level Discount-2

    [Documentation]  login another user who have no admin privilage and check jaldee finance is enabled ,


    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME5}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}

    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Suite Variable    ${pdrname}    ${decrypted_data['userName']}
    Set Suite Variable    ${pdrfname}    ${decrypted_data['firstName']}
    Set Suite Variable    ${pdrlname}    ${decrypted_data['lastName']}
    
    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}


    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}



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

    ${resp}=  Create Sample Location  
    Set Suite Variable    ${lid}    ${resp}  

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${name}=   FakerLibrary.word
    ${resp}=  Create Category   ${name}  ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id}   ${resp.json()}


    ${name1}=   FakerLibrary.word
    Set Suite Variable   ${name1}
    ${resp}=  Create Category   ${name1}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id3}   ${resp.json()}

    ${vender_name}=   FakerLibrary.firstname
    ${contactPersonName}=   FakerLibrary.lastname
    ${owner_name}=   FakerLibrary.lastname
    ${vendorId}=   FakerLibrary.word
    ${PO_Number}    Generate random string    5    123456789
    ${vendor_phno}=  Evaluate  ${PUSERNAME}+${PO_Number}
     ${vendor_phno}=  Create Dictionary  countryCode=${countryCodes[0]}   number=${vendor_phno}
    Set Test Variable  ${email}  ${vender_name}${vendor_phno}.${test_mail}
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
    Set Suite Variable   ${vendor_uid2}   ${resp.json()['uid']}
    Set Suite Variable   ${vendor_id1}   ${resp.json()['id']}

    ${resp}=  Get Vendor By Id   ${vendor_uid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${vendor_id1}
    Should Be Equal As Strings  ${resp.json()['accountId']}  ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorType']}  ${category_id}

    ${resp1}=  AddCustomer  ${CUSERNAME15}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Suite Variable  ${pcid18}   ${resp1.json()}


    ${providerConsumerIdList}=  Create List  ${pcid18}
    Set Suite Variable  ${providerConsumerIdList}  

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${invoiceLabel}=   FakerLibrary.word
    ${invoiceDate}=   db.get_date_by_timezone  ${tz}

    ${invoiceId}=   FakerLibrary.word


    ${itemName}=    FakerLibrary.word
    Set Suite Variable  ${itemName}
    ${price}=   Random Int  min=10  max=15
    ${price}=   Convert To Integer  ${price}  

    ${quantity}=   Random Int  min=100  max=150
    ${quantity}=   Convert To Integer  ${quantity}  
    ${adhocItemList}=  Create Dictionary  itemName=${itemName}   quantity=${quantity}   price=${price}
    ${adhocItemList}=    Create List    ${adhocItemList}
    ${adhocItemListnetTotal1}=  Evaluate  ${quantity} * ${price}
    Set Suite Variable  ${adhocItemListnetTotal1} 
    ${netTotal1}=   Convert To Integer  ${adhocItemListnetTotal1} 
    Set Suite Variable   ${netTotal1}
    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word

     ${item1}=     FakerLibrary.word
    ${itemCode1}=     FakerLibrary.word
    ${price1}=     Random Int   min=400   max=500
    ${price}=   Convert To Integer  ${price1}  
    Set Suite Variable  ${price} 
    ${resp}=  Create Sample Item   ${DisplayName1}   ${item1}  ${itemCode1}  ${price}  ${bool[0]} 
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${itemId1}  ${resp.json()}

    ${resp}=   Get Item By Id  ${itemId1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${promotionalPrice}   ${resp.json()['promotionalPrice']}


    ${itemList}=  Create Dictionary  itemId=${itemId1}   quantity=${quantity}  price=${promotionalPrice}
    ${itemListnetTotal}=  Evaluate  ${quantity} * ${promotionalPrice}
    Set Suite Variable   ${itemListnetTotal}
    ${netTotal}=   Convert To Integer  ${itemListnetTotal} 
    Set Suite Variable   ${netTotal}
    
    
    ${resp}=  Create Invoice   ${category_id3}    ${invoiceDate}   ${invoiceLabel}   ${address}   ${vendor_uid2}   ${invoiceId}    ${providerConsumerIdList}   ${itemList}   adhocItemList=${adhocItemList}   billStatus=${billStatus[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoice_uid1}   ${resp.json()['uidList'][0]} 

    ${discount1}=     FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${discountprice1}=     Random Int   min=50   max=100
    ${discountprice}=   Convert To Integer  ${discountprice1}  
    Set Suite Variable   ${discountprice}
    ${resp}=   Create Discount  ${discount1}   ${desc}    ${discountprice}   ${calctype[1]}  ${disctype[0]}
    Log  ${resp.json()}
    Set Suite Variable   ${discountId1}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Apply Item Level Discount   ${invoice_uid1}   ${discountId1}    ${discountprice}   ${privateNote}  ${displayNote}   ${itemId1}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dis}=  Evaluate  ${netTotal} - ${discountprice}
    Set Suite Variable   ${dis}
    ${dis}=   Convert To Integer  ${dis}  



    ${resp1}=  Get Invoice By Id  ${invoice_uid1}
    Log  ${resp1.content}

    FOR  ${p}  IN RANGE  5
        ${ran int}=    Generate Random String    length=4    chars=[NUMBERS]
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To String  ${ran int}
        ${Status}=   Run Keyword And Return Status   Should Match Regexp	${ran int}	\\d{4}
        Exit For Loop IF  ${Status}  
    END
    ${ran int}=    Convert To Integer    ${ran int}
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+${ran int}
    Set Suite Variable  ${PUSERNAME_U1}
    clear_users  ${PUSERNAME_U1}
    ${firstname1}=  FakerLibrary.name
    Set Test Variable  ${firstname1}
    ${lastname1}=  FakerLibrary.last_name
    Set Test Variable  ${lastname1}
    ${dob1}=  FakerLibrary.Date
    Set Test Variable  ${dob1}
    ${pin1}=  get_pincode
    Set Test Variable  ${pin1}

    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

   

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_id}   ${resp.json()[0]['id']}
   
    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}


JD-TC-Remove Item Level Discount-3

    [Documentation]  remove item level discount after sharing invoice,


    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME5}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${netTotal2}=  Evaluate  ${netTotal1} + ${dis}
    ${netTotal2}=   Convert To Integer  ${netTotal2}   
    ${netRate}=   Evaluate  ${netTotal1}-${dis}
    ${netRate}=   Convert To Integer  ${netRate}   
    ${amounttotal} =  Evaluate  ${netTotal} + ${netTotal1}
    ${amounttotal}=   Convert To Integer  ${amounttotal}   

    ${netrateofitem} =  Evaluate  ${itemListnetTotal} + ${adhocItemListnetTotal1}



    ${resp1}=  Get Invoice By Id  ${invoice_uid1}
    Log  ${resp1.content}
    ${rate1}=    Convert To Integer  ${resp1.json()['netTotal']} 
    ${netTotal1}=    Convert To Integer  ${resp1.json()['netRate']} 
    ${totalPrice1}=    Convert To Integer  ${resp1.json()['itemList'][0]['totalPrice']}
    ${discountprice1}=    Convert To Integer  ${resp1.json()['itemList'][0]['discountTotal']}
    ${amountTotal1}=    Convert To Integer   ${resp1.json()['amountTotal']}
    ${amountDue1}=    Convert To Integer   ${resp1.json()['amountDue']} 

    Should Be Equal As Strings  ${resp1.json()['itemList'][0]['discounts'][0]['id']}   ${discountId1}
    Should Be Equal As Strings  ${rate1}     ${netTotal2}
    Should Be Equal As Strings  ${netTotal1}     ${netTotal2}
    Should Be Equal As Strings  ${totalPrice1}   ${netTotal}
    Should Be Equal As Strings  ${discountprice1}   ${discountprice}
    # Should Be Equal As Strings  ${amountTotal1}     ${netTotal}


    ${vender_name}=   FakerLibrary.firstname
    ${PO_Number}    Generate random string    5    123456789
    ${vendor_phno}=  Evaluate  ${PUSERNAME}+${PO_Number}
     ${vendor_phno}=  Create Dictionary  countryCode=${countryCodes[0]}   number=${vendor_phno}
    Set Test Variable  ${email}  ${vender_name}${vendor_phno}.${test_mail}

    ${resp}=  Share invoice as pdf   ${invoice_uid1}   ${boolean[1]}    ${email}   ${html}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200



    ${resp}=  Remove Item Level Discount   ${invoice_uid1}   ${discountId1}    ${EMPTY}   ${EMPTY}  ${EMPTY}   ${itemId1}
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp1}=  Get Invoice By Id  ${invoice_uid1}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.json()['itemList'][0]['discounts']}   []
    # Should Be Equal As Strings  ${resp1.json()['netRate']}     ${netrateofitem}
    Should be equal    ${resp1.json()['netRate']}     ${netrateofitem}

JD-TC-Remove Item Level Discount-4

    [Documentation]  Account is taxable,item is  taxable-Create new invoice.


    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME5}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

        ${gstper}=  Random Element  ${gstpercentage}
        ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
        ${resp}=  Update Tax Percentage  ${gstper}  ${GST_num}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Enable Tax
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Get Tax Percentage
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Test Variable  ${tax_per}  ${resp.json()['taxPercentage']}

   ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${invoiceLabel}=   FakerLibrary.word
    ${invoiceDate}=   db.get_date_by_timezone  ${tz}

    ${invoiceId}=   FakerLibrary.word

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word

     ${item1}=     FakerLibrary.word
    ${itemCode1}=     FakerLibrary.word
    ${price1}=     Random Int   min=400   max=500
    # ${price}=   Convert To Integer  ${price1}  
    Set Suite Variable  ${price} 
    ${resp}=  Create Sample Item   ${DisplayName1}   ${item1}  ${itemCode1}  ${price}  ${bool[1]} 
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${itemId2}  ${resp.json()}

    ${resp}=   Get Item By Id  ${itemId2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${promotionalPrice}   ${resp.json()['promotionalPrice']}
    # ${promotionalPrice}=   Convert To Integer  ${promotionalPrice}  


    ${quantity}=   Random Int  min=5000  max=6000
    # ${quantity}=   Convert To Integer  ${quantity}  
    ${itemList}=  Create Dictionary  itemId=${itemId2}   quantity=${quantity}  price=${promotionalPrice}
    ${netTotal1}=  Evaluate  ${quantity} * ${promotionalPrice}
    Set Suite Variable   ${netTotal1}
    
    
    ${resp}=  Create Invoice   ${category_id3}    ${invoiceDate}   ${invoiceLabel}   ${address}   ${vendor_uid2}   ${invoiceId}    ${providerConsumerIdList}   ${itemList}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoice_uid3}   ${resp.json()['uidList'][0]} 

    ${discount1}=     FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${discountprice1}=     Random Int   min=50   max=100
    # ${discountprice}=   Convert To Integer  ${discountprice1}  
    Set Test Variable   ${discountprice}
    ${resp}=   Create Discount  ${discount1}   ${desc}    ${discountprice}   ${calctype[1]}  ${disctype[0]}
    Log  ${resp.json()}
    Set Test Variable   ${discountId1}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Apply Item Level Discount   ${invoice_uid3}   ${discountId1}    ${discountprice}   ${privateNote}  ${displayNote}   ${itemId2}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${netRate}=  Evaluate  ${netTotal1} - ${discountprice}
    Set Test Variable   ${netRate}


        ${netTaxAmount}=  Evaluate  ${netRate}*(${tax_per}/100)
        # ${netTaxAmount}=   Convert To Integer  ${netTaxAmount}   
        ${total_amt_with_tax}=  Evaluate  ${netRate}+${netTaxAmount}
        # ${total_amt_with_tax}=   Convert To Integer  ${total_amt_with_tax}   
        ${netTotal}=  Evaluate  ${total_amt_with_tax}+${netRate}
        # ${netTotal}=   Convert To Integer  ${netTotal}   

    ${resp1}=  Get Invoice By Id  ${invoice_uid3}
    Log  ${resp1.content}

    # ${rate1}=    Convert To Integer  ${resp1.json()['netTotal']} 
    # ${netTotal3}=    Convert To Integer  ${resp1.json()['netRate']} 
    # ${discountprice1}=    Convert To Integer  ${resp1.json()['itemList'][0]['discountTotal']}
    # ${taxableTotal1}=    Convert To Integer   ${resp1.json()['taxableTotal']} 
    # ${amountTotal1}=    Convert To Integer   ${resp1.json()['amountTotal']}
    # ${amountDue1}=    Convert To Integer   ${resp1.json()['amountDue']} 
    # ${discountValue1}=    Convert To Integer  ${resp1.json()['itemList'][0]['discounts'][0]['discountValue']}

    # Should Be Equal As Strings  ${resp1.json()['itemList'][0]['discounts'][0]['id']}   ${discountId1}
    # Should Be Equal As Strings  ${discountValue1}   ${discountprice}
    # Should Be Equal As Strings  ${resp1.json()['itemList'][0]['discounts'][0]['privateNote']}   ${privateNote}
    # Should Be Equal As Strings  ${resp1.json()['itemList'][0]['discounts'][0]['displayNote']}   ${displayNote}
    # Should Be Equal As Strings  ${discountprice1}   ${discountprice}
    # Should Be Equal As Strings  ${rate1}     ${netRate}
    # Should Be Equal As Strings  ${netTotal3}     ${total_amt_with_tax}
    # Should Be Equal As Strings  ${amountDue1}     ${total_amt_with_tax}
    # # Should Be Equal As Strings  ${amountTotal1}     ${netRate}
    # Should Be Equal As Strings  ${taxableTotal1}     ${total_amt_with_tax}

    Should Be Equal As Numbers   ${resp1.json()['itemList'][0]['discounts'][0]['id']}   ${discountId1}
    Should Be Equal As Numbers   ${resp1.json()['itemList'][0]['discountTotal']}  ${discountprice}
    Should Be Equal As Strings  ${resp1.json()['itemList'][0]['discounts'][0]['privateNote']}   ${privateNote}
    Should Be Equal As Strings  ${resp1.json()['itemList'][0]['discounts'][0]['displayNote']}   ${displayNote}
    Should Be Equal As Numbers   ${resp1.json()['netTotal']}      ${netRate}
    Should Be Equal As Numbers   ${resp1.json()['netRate']}      ${total_amt_with_tax}
    Should Be Equal As Numbers   ${resp1.json()['amountDue']}    ${total_amt_with_tax}
    # Should Be Equal As Strings  ${amountTotal1}     ${netRate}
    Should Be Equal As Numbers   ${resp1.json()['taxableTotal']}     ${total_amt_with_tax}


    ${resp}=  Remove Item Level Discount   ${invoice_uid3}   ${discountId1}    ${EMPTY}   ${EMPTY}  ${EMPTY}   ${itemId2}
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    
        ${netTaxAmount1}=  Evaluate  ${netTotal1}*(${tax_per}/100)
        # ${netTaxAmount1}=   Convert To Integer  ${netTaxAmount1}   
        ${total_amt_with_tax1}=  Evaluate  ${netTotal1}+${netTaxAmount1}
        # ${total_amt_with_tax1}=   Convert To Integer  ${total_amt_with_tax1}   
        ${netTotal1}=  Evaluate  ${total_amt_with_tax1}+${netTotal1}
        # ${netTotal1}=   Convert To Integer  ${netTotal1}   

    ${resp}=  Get Invoice By Id  ${invoice_uid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${rate11}=    Convert To Integer  ${resp1.json()['netTotal']} 
    # ${netTotal4}=    Convert To Integer  ${resp1.json()['netRate']} 
    #  ${taxableTotal11}=    Convert To Integer   ${resp1.json()['taxableTotal']} 
    # ${amountTotal11}=    Convert To Integer   ${resp1.json()['amountTotal']}
    # ${amountDue11}=    Convert To Integer   ${resp1.json()['amountDue']} 

    # Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts']}  []
    # Should Be Equal As Strings   ${rate11}     ${netTotal1}
    # Should Be Equal As Strings   ${netTotal4}     ${total_amt_with_tax1}
    # Should Be Equal As Strings  ${amountDue11}     ${total_amt_with_tax1}
    # # Should Be Equal As Strings  ${amountTotal11}     ${netTotal1}
    # Should Be Equal As Strings   ${taxableTotal11}     ${total_amt_with_tax1}

    Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts']}  []
    Should Be Equal As Strings   ${resp1.json()['netTotal']}      ${netTotal1}
    Should Be Equal As Strings   ${resp1.json()['netRate']}     ${total_amt_with_tax1}
    Should Be Equal As Strings  ${resp1.json()['amountDue']}     ${total_amt_with_tax1}
    # Should Be Equal As Strings  ${amountTotal11}     ${netTotal1}
    Should Be Equal As Strings   ${resp1.json()['taxableTotal']}    ${total_amt_with_tax1}



JD-TC-Remove Item Level Discount-5

    [Documentation]  Remove Item Level Discount where account is non taxable(service non taxable and item is taxable).


    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+3183538
    Set Test Variable   ${PUSERPH0}
    
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
   FOR  ${pos}  IN RANGE  ${dlen}  
        Set Test Variable  ${d1}  ${domresp.json()[${pos}]['domain']}
        ${sd1}  ${check}=  Get Billable Subdomain  ${d1}  ${domresp}  ${pos}  
        Set Test Variable   ${sd1}
        Exit For Loop IF     '${check}' == '${bool[1]}'
    END
    Log  ${d1}
    Log  ${sd1}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}=    Random Element    ${Genderlist}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${PUSERPH0}  ${licid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Activation  ${PUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  "${resp.json()}"    "true"
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}

    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${result}=  Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment
    Log   ${result.json()}
    Should Be Equal As Strings  ${result.status_code}  200
    ${resp}=   Get Accountsettings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appointment']}   ${bool[1]}
    

    ${accId}=  get_acc_id  ${PUSERPH0}
    Set Test Variable  ${accId}

    ${DAY1}=  get_date
    Set Test Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Test Variable  ${list}  ${list}
    ${ph1}=  Evaluate  ${PUSERPH0}+1000000000
    ${ph2}=  Evaluate  ${PUSERPH0}+2000000000
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${city}=   get_place
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${companySuffix}=  FakerLibrary.companySuffix
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  add_time  0  15
    Set Test Variable   ${sTime}
    ${eTime}=  add_time   0  45
    Set Test Variable   ${eTime}
    ${resp}=  Update Business Profile With Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${fields}=   Get subDomain level Fields  ${d1}  ${sd1}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${d1}  ${sd1}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}   

    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200




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



    
    ${resp}=  Create Sample Location  
    Set Test Variable    ${lid}    ${resp}  

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    
    ${name}=   FakerLibrary.word
    ${resp}=  Create Category   ${name}  ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${category_id}   ${resp.json()}


    ${name1}=   FakerLibrary.word
    Set Test Variable   ${name1}
    ${resp}=  Create Category   ${name1}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${category_id2}   ${resp.json()}

    ${vender_name}=   FakerLibrary.firstname
    ${contactPersonName}=   FakerLibrary.lastname
    ${owner_name}=   FakerLibrary.lastname
    ${vendorId}=   FakerLibrary.word
    ${PO_Number}    Generate random string    5    123456789
    ${vendor_phno}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${vendor_phno}=  Create Dictionary  countryCode=${countryCodes[0]}   number=${vendor_phno}
    Set Test Variable  ${email}  ${vender_name}${vendor_phno}.${test_mail}
    ${address}=  FakerLibrary.city
    Set Test Variable  ${address}
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
    
    ${resp}=  Create Vendor  ${category_id}  ${vendorId}  ${vender_name}   ${contactPersonName}    ${address}    ${state}    ${pin}   ${vendor_phno}   ${email}     bankInfo=${bankInfo}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${vendor_uid1}   ${resp.json()['uid']}
    Set Test Variable   ${vendor_id1}   ${resp.json()['id']}

    ${resp}=  Get Vendor By Id   ${vendor_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${vendor_id1}
    Should Be Equal As Strings  ${resp.json()['accountId']}  ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorType']}  ${category_id}

    ${resp1}=  AddCustomer  ${CUSERNAME11}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Test Variable  ${pcid18}   ${resp1.json()}


    ${providerConsumerIdList}=  Create List  ${pcid18}
    Set Test Variable  ${providerConsumerIdList}  

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Test Variable  ${address}
    ${invoiceLabel}=   FakerLibrary.word
    ${invoiceDate}=   db.get_date_by_timezone  ${tz}
    ${invoiceId}=   FakerLibrary.word


     ${SERVICE1}=    FakerLibrary.word
    Set Test Variable  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${service_duration}   ${status[0]}    ${btype}    ${bool[1]}    ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sid1}  ${resp.json()} 

    ${quantity}=   Random Int  min=50  max=100
    ${quantity}=   Convert To Integer  ${quantity}  
    ${serviceprice}=   Random Int  min=1000  max=1500
    ${serviceprice}=   Convert To Integer  ${serviceprice}  

    ${serviceList}=  Create Dictionary  serviceId=${sid1}   quantity=${quantity}  price=${serviceprice}
    ${serviceList}=    Create List    ${serviceList}
    ${servicenetRate}=  Evaluate  ${quantity} * ${serviceprice}
    ${servicenetRate}=   Convert To Integer  ${servicenetRate}   
    Set Test Variable   ${servicenetRate}

     ${item1}=     FakerLibrary.word
    ${itemCode1}=     FakerLibrary.word
    ${price1}=     Random Int   min=400   max=500
    ${price}=   Convert To Integer  ${price1}  
    Set Test Variable  ${price} 
    ${resp}=  Create Sample Item   ${DisplayName1}   ${item1}  ${itemCode1}  ${price}  ${bool[1]} 
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${itemId}  ${resp.json()}

    ${resp}=   Get Item By Id  ${itemId}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${promotionalPrice}   ${resp.json()['promotionalPrice']}
    ${promotionalPrice}=   Convert To Integer  ${promotionalPrice}  


    ${quantity}=   Random Int  min=1  max=5
    ${quantity}=   Convert To Integer  ${quantity}  
    ${itemList}=  Create Dictionary  itemId=${itemId}   quantity=${quantity}  price=${promotionalPrice}
    ${totalPrice}=  Evaluate  ${quantity} * ${promotionalPrice}
    ${totalPrice}=   Convert To Integer  ${totalPrice}   
    Set Test Variable   ${totalPrice}
    
    
    ${resp}=  Create Invoice   ${category_id2}   ${invoiceDate}   ${invoiceLabel}   ${address}   ${vendor_uid1}   ${invoiceId}    ${providerConsumerIdList}  ${itemList}  serviceList=${serviceList}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${invoice_uid}   ${resp.json()['uidList'][0]} 

    ${discount1}=     FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${discountprice1}=     Random Int   min=50   max=100
    ${discountprice}=   Convert To Integer  ${discountprice1}  
    Set Test Variable   ${discountprice}
    ${resp}=   Create Discount  ${discount1}   ${desc}    ${discountprice}   ${calctype[1]}  ${disctype[0]}
    Log  ${resp.json()}
    Set Test Variable   ${discountId}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Discounts 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${discountValue1}=     Random Int   min=50   max=100
    ${discountValue1}=   Convert To Integer  ${discountValue1}  


    ${resp}=  Apply Item Level Discount   ${invoice_uid}   ${discountId}    ${discountValue1}   ${privateNote}  ${displayNote}   ${itemId}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${netRate}=  Evaluate  ${totalPrice} - ${discountprice}
    Set Test Variable   ${netRate}

    #     ${netTotal}=  Evaluate  ${total_amt_with_tax}+${servicenetRate}
    #     ${netTotal}=   Convert To Integer  ${netTotal}   
        ${rate}=  Evaluate  ${netRate}+${servicenetRate}
        ${rate}=   Convert To Integer  ${rate}   
    #     ${amountTotal}=  Evaluate  ${rate}-${netTaxAmount} 
    #     ${amountTotal}=   Convert To Integer  ${amountTotal}   

    ${resp1}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp1.content}
    ${rate1}=    Convert To Integer  ${resp1.json()['netTotal']} 
    ${netTotal1}=    Convert To Integer  ${resp1.json()['netRate']} 
    ${totalPrice1}=    Convert To Integer  ${resp1.json()['itemList'][0]['totalPrice']}
    ${discountprice1}=    Convert To Integer  ${resp1.json()['itemList'][0]['discountTotal']}
    ${netRate1}=    Convert To Integer  ${resp1.json()['itemList'][0]['netRate']} 
    ${servicenetRate1}=    Convert To Integer  ${resp1.json()['serviceList'][0]['totalPrice']} 
    ${servicenetRate11}=    Convert To Integer  ${resp1.json()['serviceList'][0]['netRate']} 
    ${taxableTotal1}=    Convert To Integer   ${resp1.json()['taxableTotal']} 
    ${nonTaxableTotal1}=    Convert To Integer   ${resp1.json()['nonTaxableTotal']} 
    ${netTaxAmount1}=    Convert To Integer   ${resp1.json()['netTaxAmount']}
    ${temporaryTotalAmount1}=    Convert To Integer   ${resp1.json()['temporaryTotalAmount']} 
    ${amountTotal1}=    Convert To Integer   ${resp1.json()['amountTotal']}
    ${amountDue1}=    Convert To Integer   ${resp1.json()['amountDue']} 

    Should Be Equal As Strings  ${resp1.json()['itemList'][0]['discounts'][0]['id']}   ${discountId}
    Should Be Equal As Strings   ${totalPrice1}   ${totalPrice}
    Should Be Equal As Strings  ${discountprice1}   ${discountprice}
    Should Be Equal As Strings  ${netRate1}   ${netRate}
    Should Be Equal As Strings  ${servicenetRate1}   ${servicenetRate}
    Should Be Equal As Strings  ${servicenetRate11}   ${servicenetRate}
    Should Be Equal As Strings  ${amountDue1}     ${rate}
    Should Be Equal As Strings  ${rate1}     ${rate}
    Should Be Equal As Strings  ${netTotal1}     ${rate}
    Should Be Equal As Strings  ${taxableTotal1}     ${netRate}
    Should Be Equal As Strings  ${nonTaxableTotal1}     ${servicenetRate}
    Should Be Equal As Strings  ${netTaxAmount1}     0
    Should Be Equal As Strings  ${temporaryTotalAmount1}     ${rate}
    # Should Be Equal As Strings  ${amountTotal1}     ${rate}

    ${resp}=  Remove Item Level Discount   ${invoice_uid}   ${discountId}    ${discountValue1}   ${privateNote}  ${displayNote}   ${itemId}
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp.content}
 
    Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts']}  []

JD-TC-Remove Item Level Discount-6

    [Documentation]    Apply itemlevel discount from main account and then remove that discount from user account

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME6}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${accoun_Id}        ${resp.json()['id']}  
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${fields}=   Get subDomain level Fields  ${d1}  ${sd1}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${d1}  ${sd1}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

  




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



    
    ${resp}=  Create Sample Location  
    Set Test Variable    ${lid}    ${resp}  

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    
    ${name}=   FakerLibrary.word
    ${resp}=  Create Category   ${name}  ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${category_id}   ${resp.json()}


    ${name1}=   FakerLibrary.word
    Set Test Variable   ${name1}
    ${resp}=  Create Category   ${name1}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${category_id2}   ${resp.json()}

    ${vender_name}=   FakerLibrary.firstname
    ${contactPersonName}=   FakerLibrary.lastname
    ${owner_name}=   FakerLibrary.lastname
    ${vendorId}=   FakerLibrary.word
    ${PO_Number}    Generate random string    5    123456789
    ${vendor_phno}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${vendor_phno}=  Create Dictionary  countryCode=${countryCodes[0]}   number=${vendor_phno}
    Set Test Variable  ${email}  ${vender_name}${vendor_phno}.${test_mail}
    ${address}=  FakerLibrary.city
    Set Test Variable  ${address}
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
    
    ${resp}=  Create Vendor  ${category_id}  ${vendorId}  ${vender_name}   ${contactPersonName}    ${address}    ${state}    ${pin}   ${vendor_phno}   ${email}     bankInfo=${bankInfo}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${vendor_uid1}   ${resp.json()['uid']}
    Set Test Variable   ${vendor_id1}   ${resp.json()['id']}

    ${resp}=  Get Vendor By Id   ${vendor_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${vendor_id1}
    Should Be Equal As Strings  ${resp.json()['accountId']}  ${accoun_Id}
    # Should Be Equal As Strings  ${resp.json()['vendorType']}  ${category_id}

    ${resp1}=  AddCustomer  ${CUSERNAME11}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Test Variable  ${pcid18}   ${resp1.json()}


    ${providerConsumerIdList}=  Create List  ${pcid18}
    Set Test Variable  ${providerConsumerIdList}  

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Test Variable  ${address}
    ${invoiceLabel}=   FakerLibrary.word
    ${invoiceDate}=   db.get_date_by_timezone  ${tz}
    ${invoiceId}=   FakerLibrary.word


     ${SERVICE1}=    FakerLibrary.word
    Set Test Variable  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${service_duration}   ${status[0]}    ${btype}    ${bool[1]}    ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sid1}  ${resp.json()} 

    ${quantity}=   Random Int  min=50  max=100
    ${quantity}=   Convert To Integer  ${quantity}  
    ${serviceprice}=   Random Int  min=1000  max=1500
    ${serviceprice}=   Convert To Integer  ${serviceprice}  

    ${serviceList}=  Create Dictionary  serviceId=${sid1}   quantity=${quantity}  price=${serviceprice}
    ${serviceList}=    Create List    ${serviceList}
    ${servicenetRate}=  Evaluate  ${quantity} * ${serviceprice}
    ${servicenetRate}=   Convert To Integer  ${servicenetRate}   
    Set Test Variable   ${servicenetRate}

     ${item1}=     FakerLibrary.word
    ${itemCode1}=     FakerLibrary.word
    ${price1}=     Random Int   min=400   max=500
    ${price}=   Convert To Integer  ${price1}  
    Set Test Variable  ${price} 
    ${resp}=  Create Sample Item   ${DisplayName1}   ${item1}  ${itemCode1}  ${price}  ${bool[1]} 
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${itemId}  ${resp.json()}

    ${resp}=   Get Item By Id  ${itemId}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${promotionalPrice}   ${resp.json()['promotionalPrice']}
    ${promotionalPrice}=   Convert To Integer  ${promotionalPrice}  


    ${quantity}=   Random Int  min=1  max=5
    ${quantity}=   Convert To Integer  ${quantity}  
    ${itemList}=  Create Dictionary  itemId=${itemId}   quantity=${quantity}  price=${promotionalPrice}
    ${totalPrice}=  Evaluate  ${quantity} * ${promotionalPrice}
    ${totalPrice}=   Convert To Integer  ${totalPrice}   
    Set Test Variable   ${totalPrice}
    
    
    ${resp}=  Create Invoice   ${category_id2}   ${invoiceDate}   ${invoiceLabel}   ${address}   ${vendor_uid1}   ${invoiceId}    ${providerConsumerIdList}  ${itemList}  serviceList=${serviceList}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${invoice_uid}   ${resp.json()['uidList'][0]} 

    ${discount1}=     FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${discountprice1}=     Random Int   min=50   max=100
    ${discountprice}=   Convert To Integer  ${discountprice1}  
    Set Test Variable   ${discountprice}
    ${resp}=   Create Discount  ${discount1}   ${desc}    ${discountprice}   ${calctype[1]}  ${disctype[0]}
    Log  ${resp.json()}
    Set Test Variable   ${discountId}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Discounts 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${discountValue1}=     Random Int   min=50   max=100
    ${discountValue1}=   Convert To Integer  ${discountValue1}  


    ${resp}=  Apply Item Level Discount   ${invoice_uid}   ${discountId}    ${discountValue1}   ${privateNote}  ${displayNote}   ${itemId}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${netRate}=  Evaluate  ${totalPrice} - ${discountprice}
    Set Test Variable   ${netRate}

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Test Variable  ${dep_id}  ${resp1.json()}

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${u_id}=  Create Sample User
    Set Suite Variable  ${u_id}

    ${resp}=  Get User By Id      ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${PUSERNAME_U1}     ${resp.json()['mobileNo']}
    Set Suite Variable      ${sam_email}     ${resp.json()['email']}

    ${resp}=  SendProviderResetMail   ${sam_email}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${sam_email}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${sam_email}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp.content}


    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word


    ${resp}=  Remove Item Level Discount   ${invoice_uid}   ${discountId}    ${discountValue1}   ${privateNote}  ${displayNote}   ${itemId}
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-Remove Item Level Discount-UH1

    [Documentation]   Remove Item Level Discount that already removed..


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
        ${discountValue1}=     Random Int   min=50   max=100
    ${discountValue1}=   Convert To Integer  ${discountValue1}  

    ${resp}=  Remove Item Level Discount   ${invoice_uid}   ${discountId}    ${discountValue1}   ${privateNote}  ${displayNote}   ${itemId}
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INCORRECT_DISCOUNT_ID}

JD-TC-Remove Item Level Discount-UH2

    [Documentation]  Apply item level discount where Invoice uid is wrong.


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${invoice}=   FakerLibrary.word


    ${resp}=  Remove Item Level Discount   ${invoice}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}   ${itemId}
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_FM_INVOICE_ID}

JD-TC-Remove Item Level Discount-UH3

    [Documentation]  Apply item level discount where discount id is wrong.


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${discount}=   FakerLibrary.RandomNumber

    ${resp}=  Remove Item Level Discount   ${invoice_uid}   ${discount}    ${discountprice}   ${privateNote}  ${displayNote}   ${itemId}
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INCORRECT_DISCOUNT_ID}

JD-TC-Remove Item Level Discount-UH4

    [Documentation]  Apply item level discount where Item id is wrong.


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${item}=  FakerLibrary.RandomNumber


    ${resp}=  Remove Item Level Discount   ${invoice_uid}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}   ${item}
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${NO_ITEM_FOUND}

JD-TC-Remove Item Level Discount-UH5

    [Documentation]  Apply item level discount using another provider login.


    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word

    ${resp}=  Remove Item Level Discount   ${invoice_uid}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}   ${itemId}
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_FM_INVOICE_ID}


JD-TC-Remove Item Level Discount-UH6

    [Documentation]   Remove Item Level Discount that already removed.


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${invoiceLabel}=   FakerLibrary.word
    ${invoiceDate}=   db.get_date_by_timezone  ${tz}
    ${invoiceId}=   FakerLibrary.word



    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=   Convert To Integer  ${quantity}  
    ${serviceprice}=   Random Int  min=10  max=15
    ${serviceprice}=   Convert To Integer  ${serviceprice}  

    ${serviceList}=  Create Dictionary  serviceId=${sid1}   quantity=${quantity}  price=${serviceprice}
    ${serviceList}=    Create List    ${serviceList}

     ${item1}=     FakerLibrary.word
    ${itemCode1}=     FakerLibrary.word
    ${price1}=     Random Int   min=1000   max=5000
    ${price}=   Convert To Integer  ${price1}  
    Set Suite Variable  ${price} 
    ${resp}=  Create Sample Item   ${DisplayName1}   ${item1}  ${itemCode1}  ${price}  ${bool[1]} 
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${itemId1}  ${resp.json()}

    ${resp}=   Get Item By Id  ${itemId1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${promotionalPrice}   ${resp.json()['promotionalPrice']}


    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=   Convert To Integer  ${quantity}  
    ${itemList}=  Create Dictionary  itemId=${itemId1}   quantity=${quantity}  price=${promotionalPrice}
    
    
    ${resp}=  Create Invoice   ${category_id2}   ${invoiceDate}   ${invoiceLabel}   ${address}   ${vendor_uid1}   ${invoiceId}    ${providerConsumerIdList}  ${itemList}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoice_uid1}   ${resp.json()['uidList'][0]} 

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
        ${discountValue1}=     Random Int   min=50   max=100
    ${discountValue1}=   Convert To Integer  ${discountValue1}  


    ${resp}=  Apply Item Level Discount   ${invoice_uid}   ${discountId}    ${discountValue1}   ${privateNote}  ${displayNote}   ${itemId1}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  422

    ${resp}=  Remove Item Level Discount   ${invoice_uid1}   ${discountId}    ${discountValue1}   ${privateNote}  ${displayNote}   ${itemId1}
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INCORRECT_DISCOUNT_ID}

JD-TC-Remove Item Level Discount-UH7

    [Documentation]   update bill status as settiled and try to remove item level discount.


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp1}=  Get Invoice By Id  ${invoice_uid1}
    Log  ${resp1.content}

    ${billStatusNote}=   FakerLibrary.word
    ${resp}=  Update bill status   ${invoice_uid1}    ${billStatus[1]}    ${billStatusNote}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${INVOICE_SETTLED}=  format String   ${INVOICE_SETTLED}   ${billStatus[1]}

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
        ${discountValue1}=     Random Int   min=50   max=100
    ${discountValue1}=   Convert To Integer  ${discountValue1}  

    ${INVOICE_STATUS}=  format String   ${INVOICE_STATUS}   ${billStatus[1]}

    ${resp}=  Remove Item Level Discount   ${invoice_uid1}   ${discountId}    ${discountValue1}   ${privateNote}  ${displayNote}   ${itemId1}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVOICE_STATUS}


*** Comments ***
JD-TC-Remove Item Level Discount-3

    [Documentation]  login another user who have no admin privilage and try to remove discount from his login .-------------Will come this in next version ,when rbac comes-------------------


    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME5}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}

    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Suite Variable    ${pdrname}    ${decrypted_data['userName']}
    Set Suite Variable    ${pdrfname}    ${decrypted_data['firstName']}
    Set Suite Variable    ${pdrlname}    ${decrypted_data['lastName']}
    
    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}


    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}



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

    ${resp}=  Create Sample Location  
    Set Suite Variable    ${lid}    ${resp}  

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${name}=   FakerLibrary.word
    ${resp}=  Create Category   ${name}  ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id}   ${resp.json()}


    ${name1}=   FakerLibrary.word
    Set Suite Variable   ${name1}
    ${resp}=  Create Category   ${name1}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id2}   ${resp.json()}

    ${vender_name}=   FakerLibrary.firstname
    ${contactPersonName}=   FakerLibrary.lastname
    ${owner_name}=   FakerLibrary.lastname
    ${vendorId}=   FakerLibrary.word
    ${PO_Number}    Generate random string    5    123456789
    ${vendor_phno}=  Evaluate  ${PUSERNAME}+${PO_Number}
     ${vendor_phno}=  Create Dictionary  countryCode=${countryCodes[0]}   number=${vendor_phno}
    Set Test Variable  ${email}  ${vender_name}${vendor_phno}.${test_mail}
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
    Set Suite Variable   ${vendor_uid1}   ${resp.json()['uid']}
    Set Suite Variable   ${vendor_id1}   ${resp.json()['id']}

    ${resp}=  Get Vendor By Id   ${vendor_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${vendor_id1}
    Should Be Equal As Strings  ${resp.json()['accountId']}  ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorType']}  ${category_id}

    ${resp1}=  AddCustomer  ${CUSERNAME11}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Suite Variable  ${pcid18}   ${resp1.json()}


    ${providerConsumerIdList}=  Create List  ${pcid18}
    Set Suite Variable  ${providerConsumerIdList}  

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${invoiceLabel}=   FakerLibrary.word
    ${invoiceDate}=   db.get_date_by_timezone  ${tz}

    ${invoiceId}=   FakerLibrary.word


    ${itemName}=    FakerLibrary.word
    Set Suite Variable  ${itemName}
    ${price}=   Random Int  min=10  max=15
    ${price}=   Convert To Integer  ${price}  

    ${quantity}=   Random Int  min=10  max=15
    ${quantity}=   Convert To Integer  ${quantity}  
    ${adhocItemList}=  Create Dictionary  itemName=${itemName}   quantity=${quantity}   price=${price}
    ${adhocItemList}=    Create List    ${adhocItemList}
    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word

     ${item1}=     FakerLibrary.word
    ${itemCode1}=     FakerLibrary.word
    ${price1}=     Random Int   min=400   max=500
    ${price}=   Convert To Integer  ${price1}  
    Set Suite Variable  ${price} 
    ${resp}=  Create Sample Item   ${DisplayName1}   ${item1}  ${itemCode1}  ${price}  ${bool[1]} 
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${itemId}  ${resp.json()}

    ${resp}=   Get Item By Id  ${itemId}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${promotionalPrice}   ${resp.json()['promotionalPrice']}


    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=   Convert To Integer  ${quantity}  
    ${itemList}=  Create Dictionary  itemId=${itemId}   quantity=${quantity}  price=${promotionalPrice}
    
    
    ${resp}=  Create Invoice   ${category_id2}    ${invoiceDate}   ${invoiceLabel}   ${address}   ${vendor_uid1}   ${invoiceId}    ${providerConsumerIdList}   ${itemList}   adhocItemList=${adhocItemList}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoice_uid1}   ${resp.json()['uidList'][0]} 

    ${discount1}=     FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${discountprice1}=     Random Int   min=50   max=100
    ${discountprice}=   Convert To Integer  ${discountprice1}  
    Set Suite Variable   ${discountprice}
    ${resp}=   Create Discount  ${discount1}   ${desc}    ${discountprice}   ${calctype[1]}  ${disctype[0]}
    Log  ${resp.json()}
    Set Suite Variable   ${discountId1}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Apply Item Level Discount   ${invoice_uid1}   ${discountId1}    ${discountprice}   ${privateNote}  ${displayNote}   ${itemId}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    FOR  ${p}  IN RANGE  5
        ${ran int}=    Generate Random String    length=4    chars=[NUMBERS]
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To String  ${ran int}
        ${Status}=   Run Keyword And Return Status   Should Match Regexp	${ran int}	\\d{4}
        Exit For Loop IF  ${Status}  
    END
    ${ran int}=    Convert To Integer    ${ran int}
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+${ran int}
    Set Suite Variable  ${PUSERNAME_U1}
    clear_users  ${PUSERNAME_U1}
    ${firstname1}=  FakerLibrary.name
    Set Test Variable  ${firstname1}
    ${lastname1}=  FakerLibrary.last_name
    Set Test Variable  ${lastname1}
    ${dob1}=  FakerLibrary.Date
    Set Test Variable  ${dob1}
    ${pin1}=  get_pincode
    Set Test Variable  ${pin1}

    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

   

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_id}   ${resp.json()[0]['id']}
   
    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


        ${discountValue1}=     Random Int   min=50   max=100
    ${discountValue1}=   Convert To Integer  ${discountValue1}  
    ${resp}=  Remove Item Level Discount   ${invoice_uid1}   ${discountId1}    ${discountValue1}   ${privateNote}  ${displayNote}   ${itemId}
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INCORRECT_DISCOUNT_ID}


JD-TC-Remove Item Level Discount-4
    [Documentation]  login another user who have  admin privilage and try to remove discount from his login .-------------Will come this in next version ,when rbac comes-------------------


    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME5}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
        ${discountValue1}=     Random Int   min=50   max=100
    ${discountValue1}=   Convert To Integer  ${discountValue1}  

    ${resp}=  Apply Item Level Discount   ${invoice_uid1}   ${discountId1}    ${discountValue1}   ${privateNote}  ${displayNote}   ${itemId}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    FOR  ${p}  IN RANGE  5
        ${ran int}=    Generate Random String    length=4    chars=[NUMBERS]
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To String  ${ran int}
        ${Status}=   Run Keyword And Return Status   Should Match Regexp	${ran int}	\\d{4}
        Exit For Loop IF  ${Status}  
    END
    ${ran int}=    Convert To Integer    ${ran int}
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+${ran int}
    Set Test Variable  ${PUSERNAME_U1}
    clear_users  ${PUSERNAME_U1}
    ${firstname1}=  FakerLibrary.name
    Set Test Variable  ${firstname1}
    ${lastname1}=  FakerLibrary.last_name
    Set Test Variable  ${lastname1}
    ${dob1}=  FakerLibrary.Date
    Set Test Variable  ${dob1}
    ${pin1}=  get_pincode
    Set Test Variable  ${pin1}

    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${EMPTY}  ${bool[1]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}

   

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_id}   ${resp.json()[0]['id']}
   
    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



    ${resp}=  Remove Item Level Discount   ${invoice_uid1}   ${discountId1}    ${discountValue1}   ${privateNote}  ${displayNote}   ${itemId}
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INCORRECT_DISCOUNT_ID}





