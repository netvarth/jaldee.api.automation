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
${self}         0

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
    [Return]  ${subdomain}  ${resp.json()['serviceBillable']}



Get Non Billable Subdomain
    [Arguments]   ${domain}  ${jsondata}  ${posval}  
    ${length}=  Get Length  ${jsondata.json()[${posval}]['subDomains']}
    FOR  ${pos}  IN RANGE  ${length}
            Set Test Variable  ${subdomain}  ${jsondata.json()[${posval}]['subDomains'][${pos}]['subDomain']}
            ${resp}=   Get Sub Domain Settings    ${domain}    ${subdomain}
            Should Be Equal As Strings    ${resp.status_code}    200
            Exit For Loop IF  '${resp.json()['serviceBillable']}' == '${bool[0]}'
    END
    [Return]  ${subdomain}  ${resp.json()['serviceBillable']}



*** Test Cases ***

JD-TC-Remove Service Level Discount-1

    [Documentation]  Remove Service Level Discount.(non taxable)


    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+3381833
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


     ${SERVICE1}=    FakerLibrary.word
    Set Suite Variable  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${servicecharge}=  Convert To Number  ${servicecharge}  1
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${service_duration}   ${status[0]}    ${btype}    ${bool[1]}    ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid1}  ${resp.json()} 

    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    #     ${serviceprice}=   Random Int  min=1000  max=1500
    # ${serviceprice}=  Convert To Number  ${serviceprice}  1
    ${serviceList}=  Create Dictionary  serviceId=${sid1}   quantity=${quantity}  price=${servicecharge}
    ${serviceList}=    Create List    ${serviceList}
    ${servicenetRate}=  Evaluate  ${quantity} * ${servicecharge}
    ${servicenetRate}=  Convert To Number  ${servicenetRate}   2
    Set Suite Variable   ${servicenetRate}
    
    
    ${resp}=  Create Invoice   ${category_id2}   ${invoiceDate}   ${invoiceLabel}   ${address}   ${vendor_uid1}   ${invoiceId}    ${providerConsumerIdList}    serviceList=${serviceList}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoice_uid}   ${resp.json()['uidList'][0]} 

    ${discount1}=     FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${discountprice1}=     Random Int   min=50   max=100
    ${discountprice}=  Convert To Number  ${discountprice1}  1
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
    ${discountValue1}=  Convert To Number  ${discountValue1}  1

    ${resp}=  Apply Service Level Discount   ${invoice_uid}   ${discountId}    ${discountValue1}   ${privateNote}  ${displayNote}   ${sid1}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${netRate}=  Evaluate  ${servicenetRate} - ${discountprice}
    Set Test Variable   ${netRate}

    ${resp1}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['discounts'][0]['id']}   ${discountId}
    Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['discounts'][0]['discountValue']}   ${discountprice}
    Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['discounts'][0]['privateNote']}   ${privateNote}
    Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['discounts'][0]['displayNote']}   ${displayNote}
    Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['discountTotal']}   ${discountprice}
    Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['totalPrice']}   ${servicenetRate}
    Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['netRate']}   ${netRate}
    Should Be Equal As Strings  ${resp1.json()['netTotal']}     ${netRate}
    Should Be Equal As Strings  ${resp1.json()['amountTotal']}     ${netRate}
    Should Be Equal As Strings  ${resp1.json()['amountDue']}     ${netRate}
    Should Be Equal As Strings  ${resp1.json()['nonTaxableTotal']}     ${netRate}
    Should Be Equal As Strings  ${resp1.json()['temporaryTotalAmount']}     ${netRate}


    ${resp}=  Remove Service Level Discount   ${invoice_uid}   ${discountId}    ${discountValue1}   ${privateNote}  ${displayNote}   ${sid1}
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200



    ${resp}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts']}  []
    Should Be Equal As Strings  ${resp.json()['netTotal']}     ${servicenetRate}
    Should Be Equal As Strings  ${resp.json()['amountTotal']}     ${servicenetRate}
    Should Be Equal As Strings  ${resp.json()['amountDue']}     ${servicenetRate}
    Should Be Equal As Strings  ${resp.json()['nonTaxableTotal']}     ${servicenetRate}
    Should Be Equal As Strings  ${resp.json()['temporaryTotalAmount']}     ${servicenetRate}


JD-TC-Remove Service Level Discount-2

    [Documentation]   Account is taxable-then try to apply and remove service level discount in before(means before tax enabled) created invoice.


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word


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
        Set Suite Variable  ${tax_per}  ${resp.json()['taxPercentage']}

    # ${referenceNo}=   Random Int  min=5  max=200
    # ${referenceNo}=  Convert To String  ${referenceNo}

    # ${description}=   FakerLibrary.word
    # # Set Suite Variable  ${address}
    # ${invoiceLabel}=   FakerLibrary.word
    # ${invoiceDate}=   db.get_date_by_timezone  ${tz}

    # ${invoiceId}=   FakerLibrary.word


    #  ${SERVICE1}=    FakerLibrary.word
    # Set Suite Variable  ${SERVICE1}
    # ${desc}=   FakerLibrary.sentence
    # ${servicecharge}=   Random Int  min=100  max=500
    # ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${service_duration}   ${status[0]}    ${btype}    ${bool[1]}    ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}   
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${sid2}  ${resp.json()} 

    # ${quantity}=   Random Int  min=5  max=10
    # ${quantity}=  Convert To Number  ${quantity}  1
    #     ${serviceprice}=   Random Int  min=1000  max=1500
    # ${serviceprice}=  Convert To Number  ${serviceprice}  1
    # ${serviceList}=  Create Dictionary  serviceId=${sid2}   quantity=${quantity}  price=${serviceprice}
    # ${serviceList}=    Create List    ${serviceList}
    # ${servicenetRate}=  Evaluate  ${quantity} * ${serviceprice}
    # ${servicenetRate}=  Convert To Number  ${servicenetRate}   2
    # Set Suite Variable   ${servicenetRate}
    
    
    # ${resp}=  Create Invoice   ${category_id2}   ${invoiceDate}   ${invoiceLabel}   ${address}   ${vendor_uid1}   ${invoiceId}    ${providerConsumerIdList}    serviceList=${serviceList}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${invoice_uid1}   ${resp.json()['uidList'][0]} 


    ${resp}=   Apply Service Level Discount   ${invoice_uid}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${netRate}=  Evaluate  ${servicenetRate} - ${discountprice}
    Set Test Variable   ${netRate}

    
        # ${netTaxAmount}=  Evaluate  ${netRate}*(${tax_per}/100)
        # ${netTaxAmount}=  Convert To Number  ${netTaxAmount}   2
        # ${total_amt_with_tax}=  Evaluate  ${netRate}+${netTaxAmount}
        # ${total_amt_with_tax}=  Convert To Number  ${total_amt_with_tax}   2

    ${resp1}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp1.content}
    Should Not Contain   ${resp1.json()}    taxSettings
    Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['discounts'][0]['id']}   ${discountId}
    Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['discounts'][0]['discountValue']}   ${discountprice}
    Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['discounts'][0]['privateNote']}   ${privateNote}
    Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['discounts'][0]['displayNote']}   ${displayNote}
    Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['discountTotal']}   ${discountprice}
    Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['totalPrice']}   ${servicenetRate}
    Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['netRate']}   ${netRate}
    Should Be Equal As Strings  ${resp1.json()['netTotal']}     ${netRate}
    Should Be Equal As Strings  ${resp1.json()['amountTotal']}     ${netRate}
    Should Be Equal As Strings  ${resp1.json()['amountDue']}     ${netRate}
    Should Be Equal As Strings  ${resp1.json()['nonTaxableTotal']}     ${netRate}
    Should Be Equal As Strings  ${resp1.json()['temporaryTotalAmount']}     ${netRate}

    ${resp}=   Remove Service Level Discount   ${invoice_uid}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}  ${sid1}
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts']}  []
    Should Be Equal As Strings  ${resp.json()['netTotal']}     ${servicenetRate}
    Should Be Equal As Strings  ${resp.json()['amountTotal']}     ${servicenetRate}
    Should Be Equal As Strings  ${resp.json()['amountDue']}     ${servicenetRate}
    Should Be Equal As Strings  ${resp.json()['nonTaxableTotal']}     ${servicenetRate}
    Should Be Equal As Strings  ${resp.json()['temporaryTotalAmount']}     ${servicenetRate}

JD-TC-Remove Service Level Discount-3

    [Documentation]   Account is taxable,Service is non taxable-Create new invoice.


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word


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
        Set Suite Variable  ${tax_per}  ${resp.json()['taxPercentage']}

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
    ${servicecharge}=  Convert To Number  ${servicecharge}  1
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${service_duration}   ${status[0]}    ${btype}    ${bool[1]}    ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid2}  ${resp.json()} 

    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    #     ${serviceprice}=   Random Int  min=1000  max=1500
    # ${serviceprice}=  Convert To Number  ${serviceprice}  1
    ${serviceList}=  Create Dictionary  serviceId=${sid2}   quantity=${quantity}  price=${servicecharge}
    ${serviceList}=    Create List    ${serviceList}
    ${servicenetRate}=  Evaluate  ${quantity} * ${servicecharge}
    ${servicenetRate}=  Convert To Number  ${servicenetRate}   2
    Set Test Variable   ${servicenetRate}
    
    
    ${resp}=  Create Invoice   ${category_id2}   ${invoiceDate}   ${invoiceLabel}   ${address}   ${vendor_uid1}   ${invoiceId}    ${providerConsumerIdList}    serviceList=${serviceList}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoice_uid1}   ${resp.json()['uidList'][0]} 


    ${resp}=   Apply Service Level Discount   ${invoice_uid1}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}  ${sid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${netRate}=  Evaluate  ${servicenetRate} - ${discountprice}
    Set Test Variable   ${netRate}

    
        # ${netTaxAmount}=  Evaluate  ${netRate}*(${tax_per}/100)
        # ${netTaxAmount}=  Convert To Number  ${netTaxAmount}   2
        # ${total_amt_with_tax}=  Evaluate  ${netRate}+${netTaxAmount}
        # ${total_amt_with_tax}=  Convert To Number  ${total_amt_with_tax}   2

    ${resp1}=  Get Invoice By Id  ${invoice_uid1}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['discounts'][0]['id']}   ${discountId}
    Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['discounts'][0]['discountValue']}   ${discountprice}
    Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['discounts'][0]['privateNote']}   ${privateNote}
    Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['discounts'][0]['displayNote']}   ${displayNote}
    Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['discountTotal']}   ${discountprice}
    Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['totalPrice']}   ${servicenetRate}
    Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['netRate']}   ${netRate}
    Should Be Equal As Strings  ${resp1.json()['netTotal']}     ${netRate}
    Should Be Equal As Strings  ${resp1.json()['amountTotal']}     ${netRate}
    Should Be Equal As Strings  ${resp1.json()['amountDue']}     ${netRate}
    Should Be Equal As Strings  ${resp1.json()['nonTaxableTotal']}     ${netRate}
    Should Be Equal As Strings  ${resp1.json()['temporaryTotalAmount']}     ${netRate}

    ${resp}=   Remove Service Level Discount   ${invoice_uid1}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}  ${sid2}
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoice By Id  ${invoice_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts']}  []
    Should Be Equal As Strings  ${resp.json()['netTotal']}     ${servicenetRate}
    Should Be Equal As Strings  ${resp.json()['amountTotal']}     ${servicenetRate}
    Should Be Equal As Strings  ${resp.json()['amountDue']}     ${servicenetRate}
    Should Be Equal As Strings  ${resp.json()['nonTaxableTotal']}     ${servicenetRate}
    Should Be Equal As Strings  ${resp.json()['temporaryTotalAmount']}     ${servicenetRate}


JD-TC-Remove Service Level Discount-4

    [Documentation]   Account is taxable,Service is  taxable-Create new invoice.


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word


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
        Set Suite Variable  ${tax_per}  ${resp.json()['taxPercentage']}

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${invoiceLabel}=   FakerLibrary.word
    ${invoiceDate}=   db.get_date_by_timezone  ${tz}

    ${invoiceId}=   FakerLibrary.word


     ${SERVICE2}=    FakerLibrary.word
    Set Suite Variable  ${SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${servicecharge}=  Convert To Number  ${servicecharge}  1
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${service_duration}   ${status[0]}    ${btype}    ${bool[1]}    ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[1]}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid3}  ${resp.json()} 

    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    #     ${serviceprice}=   Random Int  min=1000  max=1500
    # ${serviceprice}=  Convert To Number  ${serviceprice}  1
    ${serviceList}=  Create Dictionary  serviceId=${sid3}   quantity=${quantity}  price=${servicecharge}
    ${serviceList}=    Create List    ${serviceList}
    ${servicenetRate}=  Evaluate  ${quantity} * ${servicecharge}
    ${servicenetRate}=  Convert To Number  ${servicenetRate}   2
    Set Test Variable   ${servicenetRate}
    
    
    ${resp}=  Create Invoice   ${category_id2}   ${invoiceDate}   ${invoiceLabel}   ${address}   ${vendor_uid1}   ${invoiceId}    ${providerConsumerIdList}    serviceList=${serviceList}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoice_uid2}   ${resp.json()['uidList'][0]} 


    ${resp}=   Apply Service Level Discount   ${invoice_uid2}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}  ${sid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${netRate}=  Evaluate  ${servicenetRate} - ${discountprice}
    Set Test Variable   ${netRate}

    
        ${netTaxAmount}=  Evaluate  ${netRate}*(${tax_per}/100)
        ${netTaxAmount}=  Convert To Number  ${netTaxAmount}   2
        ${total_amt_with_tax}=  Evaluate  ${netRate}+${netTaxAmount}
        ${total_amt_with_tax}=  Convert To Number  ${total_amt_with_tax}   2
        ${netTotal}=  Evaluate  ${total_amt_with_tax}+${servicenetRate}
        ${netTotal}=  Convert To Number  ${netTotal}   2

    ${resp1}=  Get Invoice By Id  ${invoice_uid2}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['discounts'][0]['id']}   ${discountId}
    Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['discounts'][0]['discountValue']}   ${discountprice}
    Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['discounts'][0]['privateNote']}   ${privateNote}
    Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['discounts'][0]['displayNote']}   ${displayNote}
    Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['discountTotal']}   ${discountprice}
    Should Be Equal As Strings  ${resp1.json()['netTotal']}     ${netRate}
    Should Be Equal As Strings  ${resp1.json()['netRate']}     ${total_amt_with_tax}
    Should Be Equal As Strings  ${resp1.json()['amountDue']}     ${total_amt_with_tax}
    Should Be Equal As Strings  ${resp1.json()['amountTotal']}     ${netRate}
    Should Be Equal As Strings  ${resp1.json()['taxableTotal']}     ${total_amt_with_tax}
    # Should Be Equal As Strings  ${resp1.json()['amountDue']}     ${netRate}
    # Should Be Equal As Strings  ${resp1.json()['temporaryTotalAmount']}     ${rate}
    # Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['totalPrice']}   ${servicenetRate}
    # Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['netRate']}   ${netRate}



    # Should Be Equal As Strings  ${resp1.json()['nonTaxableTotal']}     ${netRate}
    # Should Be Equal As Strings  ${resp1.json()['temporaryTotalAmount']}     ${netRate}

    ${resp}=   Remove Service Level Discount   ${invoice_uid2}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}  ${sid3}
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200

    
        ${netTaxAmount1}=  Evaluate  ${servicenetRate}*(${tax_per}/100)
        ${netTaxAmount1}=  Convert To Number  ${netTaxAmount1}   2
        ${total_amt_with_tax1}=  Evaluate  ${servicenetRate}+${netTaxAmount1}
        ${total_amt_with_tax1}=  Convert To Number  ${total_amt_with_tax1}   2
        ${netTotal1}=  Evaluate  ${total_amt_with_tax1}+${servicenetRate}
        ${netTotal1}=  Convert To Number  ${netTotal1}   2

    ${resp}=  Get Invoice By Id  ${invoice_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts']}  []
    Should Be Equal As Strings  ${resp1.json()['netTotal']}     ${servicenetRate}
    Should Be Equal As Strings  ${resp1.json()['netRate']}     ${total_amt_with_tax1}
    Should Be Equal As Strings  ${resp1.json()['amountDue']}     ${total_amt_with_tax1}
    Should Be Equal As Strings  ${resp1.json()['amountTotal']}     ${servicenetRate}
    Should Be Equal As Strings  ${resp1.json()['taxableTotal']}     ${total_amt_with_tax1}



JD-TC-Remove Service Level Discount-5

    [Documentation]   Service auto invoice generation is on,then took one appointment from consumer side  and check whethrer invoice is created there .


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}

    ${pid}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME32}

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word

    ${resp}=  Create Sample Location  
    Set Suite Variable    ${lid}    ${resp}  

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    # Set Suite Variable  ${CUR_DAY}
  
    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${servicecharge}=  Convert To Number  ${servicecharge}  1 
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    ${resp}=  Auto Invoice Generation For Service   ${s_id}    ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[1]}


    clear_appt_schedule   ${PUSERPH0}

    ${resp}=  Get Appointment Schedules
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.add_timezone_time     ${tz}  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Consumer Login  ${CUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-3}
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}    location=${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
    Set Suite Variable   ${apptid1}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response    ${resp}     uid=${apptid1}   appmtDate=${DAY1}   appmtTime=${slot1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}  ${apptStatus[0]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    sleep  02s

    ${resp}=  Encrypted Provider Login    ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    sleep  02s
    ${resp1}=  Get Bookings Invoices  ${apptid1}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200

JD-TC-Remove Service Level Discount-6

    [Documentation]   Service auto invoice generation is on,then took walkin appointment  and check whethrer invoice is created there .

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname1}   ${resp.json()['firstName']}
    Set Test Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}

    ${pid}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME32}

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${lid}=  Create Sample Location  
    Set Suite Variable  ${lid}
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    clear_appt_schedule   ${PUSERPH0}

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${servicecharge}=  Convert To Number  ${servicecharge}  1 
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}

    ${resp}=  Auto Invoice Generation For Service   ${s_id}    ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[1]}
    Set Test Variable   ${tot_amt}   ${resp.json()['totalAmount']}


    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}   ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME2}   firstName=${fname1}   lastName=${lname1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable   ${jaldeeid1}    ${resp.json()[0]['jaldeeId']}
    
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[1]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}                              ${apptid1}
    Should Be Equal As Strings  ${resp.json()['appointmentEncId']}                  ${encId}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}        ${CUSERNAME2}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['jaldeeId']}      ${jaldeeid1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                      ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                      ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                          ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}             ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}              ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}              ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                            ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}                            ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                       ${lid}

    ${resp1}=  Get Bookings Invoices  ${apptid1}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()[0]['netTotal']}     ${tot_amt}
    Should Be Equal As Strings  ${resp1.json()[0]['netRate']}     ${tot_amt}
    Should Be Equal As Strings  ${resp1.json()[0]['amountDue']}     ${tot_amt}
    Should Be Equal As Strings  ${resp1.json()[0]['amountTotal']}     ${tot_amt}

JD-TC-Remove Service Level Discount-7

    [Documentation]   Service auto invoice generation is off,then took one appointment from consumer side  and check  invoice is not created there .then create invoice.


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}

    ${pid}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME32}

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word

    ${resp}=  Create Sample Location  
    Set Suite Variable    ${lid}    ${resp}  

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    # Set Suite Variable  ${CUR_DAY}
  
    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${servicecharge}=  Convert To Number  ${servicecharge}  1 
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    ${resp}=  Auto Invoice Generation For Service   ${s_id}    ${toggle[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[0]}

    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1

    ${serviceList}=  Create Dictionary  serviceId=${s_id}   quantity=${quantity}  price=${servicecharge}
    ${serviceList}=    Create List    ${serviceList}
    ${servicenetRate}=  Evaluate  ${quantity} * ${servicecharge}
    ${servicenetRate}=  Convert To Number  ${servicenetRate}   2
    Set Test Variable   ${servicenetRate}


    clear_appt_schedule   ${PUSERPH0}

    ${resp}=  Get Appointment Schedules
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.add_timezone_time     ${tz}  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Consumer Login  ${CUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-3}
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}    location=${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
    Set Suite Variable   ${apptid1}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response    ${resp}     uid=${apptid1}   appmtDate=${DAY1}   appmtTime=${slot1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}  ${apptStatus[0]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    sleep  02s

    ${resp}=  Encrypted Provider Login    ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    sleep  02s
     ${NO_INVOICE_GENERATED}=  format String   ${NO_INVOICE_GENERATED}   ${apptid1}
    ${resp1}=  Get Bookings Invoices  ${apptid1}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  422
    Should Be Equal As Strings  ${resp1.json()}   ${NO_INVOICE_GENERATED}


    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${invoiceLabel}=   FakerLibrary.word
    ${invoiceDate}=   db.get_date_by_timezone  ${tz}

    ${invoiceId}=   FakerLibrary.word

    
    
    ${resp}=  Create Invoice   ${category_id2}   ${invoiceDate}   ${invoiceLabel}   ${address}   ${vendor_uid1}   ${invoiceId}    ${providerConsumerIdList}    serviceList=${serviceList}   ynwUuid=${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${invoice_uid1}   ${resp.json()['uidList'][0]} 

    ${resp1}=  Get Invoice By Id  ${invoice_uid1}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Not Contain    ${resp1.json()['serviceList'][0]}   discounts
    # Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['discounts']}  []
    Should Be Equal As Strings  ${resp1.json()['netTotal']}     ${servicenetRate}
    Should Be Equal As Strings  ${resp1.json()['netRate']}     ${servicenetRate}
    Should Be Equal As Strings  ${resp1.json()['amountDue']}     ${servicenetRate}
    Should Be Equal As Strings  ${resp1.json()['amountTotal']}     ${servicenetRate}
    # Should Be Equal As Strings  ${resp1.json()['taxableTotal']}     ${servicecharge}





JD-TC-Remove Service Level Discount-UH1

    [Documentation]   Remove Service Level Discount that already removed..


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
        ${discountValue1}=     Random Int   min=50   max=100
    ${discountValue1}=  Convert To Number  ${discountValue1}  1

    ${resp}=   Remove Service Level Discount   ${invoice_uid1}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}  ${sid2}
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INCORRECT_DISCOUNT_ID}

JD-TC-Remove Service Level Discount-UH2

    [Documentation]  Remove Service Level Discount where Invoice uid is wrong.


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${invoice}=   FakerLibrary.word

    ${resp}=   Remove Service Level Discount   ${invoice}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}  ${sid3}
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_FM_INVOICE_ID}

JD-TC-Remove Service Level Discount-UH3

    [Documentation]  Remove Service Level Discount where discount id is wrong.


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${discount}=   FakerLibrary.RandomNumber

    ${resp}=   Remove Service Level Discount   ${invoice_uid1}   ${discount}    ${discountprice}   ${privateNote}  ${displayNote}  ${sid2}
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INCORRECT_DISCOUNT_ID}

JD-TC-Remove Service Level Discount-UH4

    [Documentation]  Remove Service Level Discount where serviceid is wrong.


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${item}=  FakerLibrary.RandomNumber


    ${resp}=   Remove Service Level Discount   ${invoice_uid2}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}  ${item}
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${SERVICE_NOT}

JD-TC-Remove Service Level Discount-UH5

    [Documentation]  Remove Service Level Discount using another provider login.


    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word

    ${resp}=   Remove Service Level Discount   ${invoice_uid2}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}  ${sid3}
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  ${resp.json()}   ${INVALID_FM_INVOICE_ID}
    Should Be Equal As Strings  ${resp.json()}   ${CAP_JALDEE_FINANCE_DISABLED}

JD-TC-Remove Service Level Discount-UH6

    [Documentation]   Service auto invoice generation is off by default,then took one appointment from consumer side  and check  invoice is not created there .


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}

    ${pid}=  get_acc_id  ${PUSERPH0}
    ${cid}=  get_id  ${CUSERNAME32}

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word

    ${resp}=  Create Sample Location  
    Set Suite Variable    ${lid}    ${resp}  

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    # Set Suite Variable  ${CUR_DAY}
  
    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${servicecharge}=  Convert To Number  ${servicecharge}  1 
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    # ${resp}=  Auto Invoice Generation For Service   ${s_id}    ${toggle[1]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  422

    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[0]}

    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1

    ${serviceList}=  Create Dictionary  serviceId=${s_id}   quantity=${quantity}  price=${servicecharge}
    ${serviceList}=    Create List    ${serviceList}
    ${servicenetRate}=  Evaluate  ${quantity} * ${servicecharge}
    ${servicenetRate}=  Convert To Number  ${servicenetRate}   2
    Set Test Variable   ${servicenetRate}


    clear_appt_schedule   ${PUSERPH0}

    ${resp}=  Get Appointment Schedules
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.add_timezone_time     ${tz}  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Consumer Login  ${CUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-3}
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}    location=${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
    Set Suite Variable   ${apptid1}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response    ${resp}     uid=${apptid1}   appmtDate=${DAY1}   appmtTime=${slot1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}  ${apptStatus[0]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    sleep  02s

    ${resp}=  Encrypted Provider Login    ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    sleep  02s
     ${NO_INVOICE_GENERATED}=  format String   ${NO_INVOICE_GENERATED}   ${apptid1}
    ${resp1}=  Get Bookings Invoices  ${apptid1}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  422
    Should Be Equal As Strings  ${resp1.json()}   ${NO_INVOICE_GENERATED}

JD-TC-Remove Service Level Discount-UH7

    [Documentation]  update bill status and try to Remove Service Level Discount .


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp1}=  Get Invoice By Id  ${invoice_uid2}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=  Update bill status   ${invoice_uid2}    ${billStatus[0]}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update bill status   ${invoice_uid2}    ${billStatus[1]}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${INVOICE_SETTLED}=  format String   ${INVOICE_SETTLED}   ${billStatus[1]}

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word

    ${resp}=   Remove Service Level Discount   ${invoice_uid2}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}  ${sid3}
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVOICE_SETTLED}
