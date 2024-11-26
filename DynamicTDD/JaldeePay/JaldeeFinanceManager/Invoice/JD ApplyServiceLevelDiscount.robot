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
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Variables ***

@{service_names}

${service_duration}     30


*** Test Cases ***

JD-TC-Apply Service Level Discount-1

    [Documentation]  Apply Service Level Discount.

    ${firstname}  ${lastname}  ${PUSERPH10}  ${LoginId}=  Provider Signup
    Set Suite Variable  ${PUSERPH10}



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

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Get Bill Settings 
    Log   ${resp.json}
    IF  ${resp.status_code}!=200
        Log   Status code is not 200: ${resp.status_code}
        ${resp}=  Enable Disable bill  ${bool[1]}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    ELSE IF  ${resp.json()['enablepos']}==${bool[0]}
        ${resp}=  Enable Disable bill  ${bool[1]}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Bill Settings 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['enablepos']}    ${bool[1]}

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
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${name}=   FakerLibrary.word
    ${resp}=  CreateVendorCategory  ${name}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id}   ${resp.json()}

    ${resp}=  Get by encId  ${category_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


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


     ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Set Suite Variable  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${service_duration}  ${bool[0]}  ${servicecharge}  ${bool[1]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid1}  ${resp.json()} 

    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    ${servicecharge}=  Convert To Number  ${servicecharge}  1
    Set Suite Variable  ${servicecharge}

    ${serviceList}=  Create Dictionary  serviceId=${sid1}   quantity=${quantity}   price=${servicecharge} 
    ${serviceList}=    Create List    ${serviceList}

    ${netrateofservice}=  Evaluate  ${servicecharge}*${quantity}
    Set Suite Variable  ${netrateofservice}
    
    
    ${resp}=  Create Invoice   ${category_id2}    ${invoiceDate}      ${invoiceId}    ${providerConsumerIdList}   ${lid}   serviceList=${serviceList}
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




    ${resp}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][0]['id']}  ${discountId}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][0]['name']}  ${discount1}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][0]['discountType']}  ${disctype[0]}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][0]['discountValue']}  ${discountprice}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][0]['calculationType']}  ${calctype[1]}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][0]['privateNote']}  ${privateNote}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][0]['displayNote']}  ${displayNote}


JD-TC-Apply Service Level Discount-2

    [Documentation]   Apply discount with empty private note and display note.



    ${resp}=   Encrypted Provider Login  ${PUSERPH10}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${discount1}=     FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${discountprice1}=     Random Int   min=50   max=100
    ${discountprice2}=  Convert To Number  ${discountprice1}  1
    Set Suite Variable   ${discountprice2}
    ${resp}=   Create Discount  ${discount1}   ${desc}    ${discountprice2}   ${calctype[1]}  ${disctype[0]}
    Log  ${resp.json()}
    Set Suite Variable   ${discountId1}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Discounts 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${discountValue1}=     Random Int   min=50   max=100
    ${discountValue1}=  Convert To Number  ${discountValue1}  1



    ${resp}=   Apply Service Level Discount   ${invoice_uid}   ${discountId1}    ${discountprice2}   ${EMPTY}  ${EMPTY}  ${sid1}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][1]['id']}  ${discountId1}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][1]['name']}  ${discount1}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][1]['discountType']}  ${disctype[0]}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][1]['discountValue']}  ${discountprice2}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][1]['calculationType']}  ${calctype[1]}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][1]['privateNote']}  ${EMPTY}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][1]['displayNote']}  ${EMPTY}


JD-TC-Apply Service Level Discount--3

    [Documentation]   create discount and remove that then apply discount.



    ${resp}=   Encrypted Provider Login  ${PUSERPH10}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=   Get Discounts 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word

    ${resp}=  Remove Service Level Discount   ${invoice_uid}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}   ${sid1}
    Log  ${resp.json()}  
    Set Suite Variable   ${rmvid}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['discounts']}  []

    ${resp}=   Get Discounts 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   Apply Service Level Discount   ${invoice_uid}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}  ${sid1}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][1]['id']}  ${discountId}

JD-TC-Apply Service Level Discount-4

    [Documentation]   create percentage type discount apply discount.



    ${resp}=   Encrypted Provider Login  ${PUSERPH10}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${discount1}=     FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${discountprice1}=     Random Int   min=50   max=100
    ${discountprice4}=  Convert To Number  ${discountprice1}  1
    Set Test Variable   ${discountprice4}
    ${resp}=   Create Discount  ${discount1}   ${desc}    ${discountprice4}   ${calctype[0]}  ${disctype[0]}
    Log  ${resp.json()}
    Set Test Variable   ${discountId4}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Discounts 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${discAmt}=    Evaluate  ${netrateofservice}-${discountprice}
    ${discAmt1}=    Evaluate  ${discAmt}-${discountprice2}
    ${dispercentage}=  Evaluate  ${discAmt1}*${discountprice4}
    ${discountpercentage}=   Evaluate  ${dispercentage}/100


    ${discountValue1}=     Random Int   min=50   max=100
    ${discountValue1}=  Convert To Number  ${discountValue1}  1



    ${resp}=   Apply Service Level Discount   ${invoice_uid}   ${discountId4}    ${discountprice4}   ${EMPTY}  ${EMPTY}  ${sid1}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][2]['id']}  ${discountId4}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][2]['name']}  ${discount1}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][2]['discountType']}  ${disctype[0]}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][2]['discountValue']}  ${discountpercentage}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][2]['calculationType']}  ${calctype[0]}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][2]['privateNote']}  ${EMPTY}
    Should Be Equal As Strings  ${resp.json()['serviceList'][0]['discounts'][2]['displayNote']}  ${EMPTY}






JD-TC-Apply Service Level Discount-UH1

    [Documentation]   apply already applied discount.


  ${resp}=   Encrypted Provider Login  ${PUSERPH10}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word


    ${resp}=   Apply Service Level Discount   ${invoice_uid}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${DISCOUNT_ALREADY_USED}

JD-TC-Apply Service Level Discount-UH2

    [Documentation]   Discount is higher than invoice amount.


    ${resp}=   Encrypted Provider Login  ${PUSERPH10}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${discount1}=     FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${discountprice1}=     Random Int   min=6000   max=8000
    ${discountpriceUH}=  Convert To Number  ${discountprice1}  1
    Set Suite Variable   ${discountpriceUH}
    ${resp}=   Create Discount  ${discount1}   ${desc}    ${discountpriceUH}   ${calctype[1]}  ${disctype[0]}
    Log  ${resp.json()}
    Set Test Variable   ${discountId}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Discounts 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${discountValue1}=     Random Int   min=50   max=100
    ${discountValue1}=  Convert To Number  ${discountValue1}  1


    ${resp}=   Apply Service Level Discount   ${invoice_uid}   ${discountId}    ${discountpriceUH}   ${privateNote}  ${displayNote}  ${sid1}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${NEED_AMOUNT_HIGHER_THAN_DISCOUNT}

JD-TC-Apply Service Level Discount-UH3

    [Documentation]   Apply discount with discount price is empty.


    ${resp}=   Encrypted Provider Login  ${PUSERPH10}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word


     ${resp}=   Apply Service Level Discount   ${invoice_uid}   ${discountId}    ${EMPTY}   ${privateNote}  ${displayNote}  ${sid1}
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${DISCOUNT_ALREADY_USED}

JD-TC-Apply Service Level Discount-UH4

    [Documentation]   Apply discount where invoice_uid is wrong.

    ${resp}=   Encrypted Provider Login  ${PUSERPH10}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${invoice}=   FakerLibrary.word


    ${resp}=   Apply Service Level Discount   ${invoice}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}  ${sid1}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  ${resp.json()}    ${DISCOUNT_ALREADY_USED}

JD-TC-Apply Service Level Discount-UH5

    [Documentation]   Apply discount where discountid is wrong.


    ${resp}=   Encrypted Provider Login  ${PUSERPH10}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${wrodiscount}=   Random Int  min=7000  max=7500


    ${resp}=   Apply Service Level Discount   ${invoice_uid}   ${wrodiscount}    ${discountprice}   ${privateNote}  ${displayNote}  ${sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${INCORRECT_DISCOUNT_ID}

JD-TC-Apply Service Level Discount-UH6

    [Documentation]   Apply Service Level Discount where service id is wrong.


    ${resp}=   Encrypted Provider Login  ${PUSERPH10}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${serviceid}=   FakerLibrary.RandomNumber

    ${resp}=   Apply Service Level Discount   ${invoice_uid}   ${EMPTY}    ${discountprice}   ${privateNote}  ${displayNote}  ${serviceid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${SERVICE_NOT}

JD-TC-Apply Service Level Discount-UH7

    [Documentation]   Apply one service thats not added to any invoice then try to remove apply itemlevel discount using this service id.


    ${resp}=   Encrypted Provider Login  ${PUSERPH10}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=   Get Discounts 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

     ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Set Suite Variable  ${SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${service_duration}  ${bool[0]}  ${servicecharge}  ${bool[1]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid}  ${resp.json()} 

    ${resp}=   Apply Service Level Discount   ${invoice_uid}   ${discountId}    ${discountprice}   ${EMPTY}  ${EMPTY}  ${sid}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${SERVICE_NOT}
















