*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        TAX
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

***Variables***
${a}  20
*** Test Cases ***

JD-TC-Update Tax Percentage-1
       [Documentation]   Update Tax valid provider
       ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${gstper}=  Random Element  ${gstpercentage}
       ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
       Set Suite Variable  ${GSTNO}   ${GST_num}
       ${resp}=  Update Tax Percentage  ${gstper}  ${GST_num}
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=  Enable Tax
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=   Get Tax Percentage 
       Should Be Equal As Strings    ${resp.status_code}   200
       Should Be Equal As Strings   ${resp.json()['taxPercentage']}   ${gstper}
       Should Be Equal As Strings   ${resp.json()['gstNumber']}   ${GST_num}

JD-TC-Update Tax Percentage-2
       [Documentation]  Update Tax in non billable domain provider
       ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
       ${len}=   Split to lines  ${resp}
       ${length}=  Get Length   ${len}
     
       FOR   ${a}  IN RANGE   ${length}
        ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200

       ${decrypted_data}=  db.decrypt_data  ${resp.content}
       Log  ${decrypted_data}
       ${domain}=   Set Variable    ${decrypted_data['sector']}
       ${subdomain}=    Set Variable      ${decrypted_data['subSector']}

        ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Test Variable  ${check}  ${resp2.json()['pos']}
        Exit For Loop IF     "${check}" == "False"
       END
       ${gstper}=  Random Element  ${gstpercentage}
       ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
       ${resp}=  Update Tax Percentage  ${gstper}  ${GST_num}
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=  Enable Tax
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=   Get Tax Percentage 
       Should Be Equal As Strings    ${resp.status_code}   200
       Should Be Equal As Strings   ${resp.json()['taxPercentage']}   ${gstper}
       Should Be Equal As Strings   ${resp.json()['gstNumber']}   ${GST_num}

JD-TC-Update Tax Percentage -3
       [Documentation]  create bill with changed tax
       ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       clear_customer   ${PUSERNAME26}
       
       ${description}=  FakerLibrary.sentence
       ${notifytype}=    Random Element     ${notifytype}
       ${duration}=  Random Int  min=1  max=5
       ${amount}=  FakerLibrary.pyfloat  left_digits=2   right_digits=0    positive=True
       Set Suite Variable  ${amount}
       ${SERVICE1}   FakerLibrary.word
       Set Suite Variable  ${SERVICE1}
       clear_location  ${PUSERNAME26}
       ${resp}=  Create Service  ${SERVICE1}  ${description}   ${duration}  ACTIVE  Waitlist  ${bool[1]}  ${notifytype}  0  ${amount}  ${bool[0]}  ${bool[1]}
       Should Be Equal As Strings  ${resp.status_code}  200
       Set Suite Variable  ${s_id1}  ${resp.json()}
       
       ${description}=  FakerLibrary.sentence
       ${gstper}=  Random Element  ${gstpercentage}
       ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
       ${resp}=  Update Tax Percentage  ${gstper}  ${GST_num}
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=  Enable Tax
       Should Be Equal As Strings    ${resp.status_code}   200

       ${resp}=  Create Sample Location
       Set Test Variable    ${loc_id}   ${resp} 

       ${resp}=   Get Location By Id   ${loc_id} 
       Log  ${resp.content}
       Should Be Equal As Strings  ${resp.status_code}  200
       Set Test Variable  ${tz}  ${resp.json()['timezone']}

       ${DAY1}=  db.get_date_by_timezone  ${tz} 
       ${q_name}=    FakerLibrary.name
       ${list}=  Create List   1  2  3  4  5  6  7
       ${strt_time}=   add_timezone_time  ${tz}  1  00  
       ${end_time}=    add_timezone_time  ${tz}  6  00   
       ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
       ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
       ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${loc_id}  ${s_id1}
       Log   ${resp.json()}
       Should Be Equal As Strings  ${resp.status_code}  200
       Set Test Variable  ${qid}   ${resp.json()}
       
       ${resp}=  AddCustomer  ${CUSERNAME1}
       Log   ${resp.json()}
       Should Be Equal As Strings  ${resp.status_code}  200
       Set Suite Variable  ${cid}  ${resp.json()}

       # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
       # Should Be Equal As Strings  ${resp.status_code}  200
       # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
       ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid}  ${DAY1}  ${description}  ${bool[1]}  ${cid}
       Log  ${resp.json()}
       Should Be Equal As Strings  ${resp.status_code}  200
       
       ${wid}=  Get Dictionary Values  ${resp.json()}
       Set Suite Variable  ${wid}  ${wid[0]}       
       ${resp}=  Get Bill By UUId  ${wid}
       Log   ${resp.json()}
       Should Be Equal As Strings  ${resp.status_code}  200    
       ${taxtotal}=  Evaluate  ${amount}/100*${gstper}
       ${taxtotal}=  Round Val  ${taxtotal}  2
       # ${taxtotal}=  Evaluate  round(${taxtotal}) 
       # ${taxtotal}=  roundoff      ${taxtotal}
       ${due}=  Evaluate  ${amount}+${taxtotal}
       ${due}=  Round Val  ${due}  2
       # ${due}=  Evaluate  round(${due}) 
       
       Verify Response  ${resp}  uuid=${wid}  netTotal=${amount}  billStatus=New  billViewStatus=Notshow   billPaymentStatus=NotPaid  totalAmountPaid=0.0  
       # taxableTotal=${amount}  totalTaxAmount=${taxtotal}
       Should Be Equal As Numbers  ${resp.json()['totalTaxAmount']}  ${taxtotal}
       Should Be Equal As Numbers  ${resp.json()['taxableTotal']}  ${amount}
       Should Be Equal As Numbers  ${resp.json()['netRate']}  ${due}    
       Should Be Equal As Numbers  ${resp.json()['amountDue']}  ${due}  
       Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}
       Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1} 
       Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
       Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   ${gstper} 
       Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${amount}
       Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${amount}      
     
JD-TC-Update Tax Percentage-UH1

       [Documentation]   Update tax above 100 %

       ${resp}=   Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${gstper}=  FakerLibrary.pyfloat  left_digits=3   right_digits=1    positive=True
       ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
       ${resp}=  Update Tax Percentage  ${gstper}  ${GST_num}
       Should Be Equal As Strings    ${resp.status_code}   422       
       Should Be Equal As Strings  "${resp.json()}"  "${ENTER_VALID_TAX_PERCENTAGE}"   

JD-TC-Update Tax Percentage-UH2
       [Documentation]   consumer try to update Tax
       ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
       Should Be Equal As Strings  ${resp.status_code}  200 
       ${gstper}=  Random Element  ${gstpercentage}
       ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
       ${resp}=  Update Tax Percentage  ${gstper}  ${GST_num}
       Should Be Equal As Strings    ${resp.status_code}   401 
       Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-Update Tax Percentage-UH3
       [Documentation]   without login to update Tax
       ${gstper}=  Random Element  ${gstpercentage}
       ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
       ${resp}=  Update Tax Percentage  ${gstper}  ${GST_num}
       Should Be Equal As Strings    ${resp.status_code}   419
       Should Be Equal As Strings  "${resp.json()}"    "${SESSION_EXPIRED}"

JD-TC-Update Tax Percentage-UH4
       [Documentation]  Update Tax GSTno greater than 15
       ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${gstper}=  Random Element  ${gstpercentage}
       ${resp}=  Update Tax Percentage  ${gstper}  16DEFBV1100M2Y21
       Should Be Equal As Strings    ${resp.status_code}   422
       Should Be Equal As Strings  "${resp.json()}"    "${GST_NUMBER_TOO_LONG_OR_TOO_SHORT}"

JD-TC-Update Tax Percentage-UH5
       [Documentation]  Update Tax GSTno less than 15
       ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${gstper}=  Random Element  ${gstpercentage}
       ${resp}=  Update Tax Percentage  ${gstper}  16DEFBV1100M2Z
       Should Be Equal As Strings    ${resp.status_code}   422  
       Should Be Equal As Strings  "${resp.json()}"    "${GST_NUMBER_TOO_LONG_OR_TOO_SHORT}"     

JD-TC-Update Tax Percentage-UH6
       [Documentation]  Update Tax GST tax is empty
       ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
       ${resp}=  Update Tax Percentage  ${NONE}  ${GST_num}
       Should Be Equal As Strings    ${resp.status_code}   422  
       Should Be Equal As Strings  "${resp.json()}"    "${ENTER_VALID_TAX_PERCENTAGE}"            

JD-TC-Update Tax Percentage-UH7
       [Documentation]  Update Tax is zero 
       ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
       ${resp}=  Update Tax Percentage  0  ${GST_num}
       Should Be Equal As Strings    ${resp.status_code}   422
       Should Be Equal As Strings  "${resp.json()}"  "${ENTER_VALID_TAX_PERCENTAGE}"

JD-TC-Update Tax Percentage-UH8
       [Documentation]  Update Tax is negative No 
       ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${gstper}=  Random Element  ${gstpercentage}
       ${gstper}=  Evaluate  ${gstper}*-1
       ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
       ${resp}=  Update Tax Percentage  ${gstper}  ${GST_num}
       Should Be Equal As Strings    ${resp.status_code}   422 
       Should Be Equal As Strings  "${resp.json()}"    "${ENTER_VALID_TAX_PERCENTAGE}"       

JD-TC-Update Tax Percentage-UH9
       [Documentation]  Update gst number with an already existing number 
       ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${gstper}=  Random Element  ${gstpercentage}
       ${resp}=  Update Tax Percentage  ${gstper}  ${GSTNO}
       Log  ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}   422 
       Should Be Equal As Strings  "${resp.json()}"    "${GST_NUM_EXISTS}"    


*** Comments ***
JD-TC-Update Tax Percentage -3 Verification
       ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${description}=  FakerLibrary.sentence
       ${gstper}=  Random Element  ${gstpercentage}
       ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
       ${resp}=  Update Tax Percentage  ${gstper}  ${GST_num}
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=  Enable Tax
       Should Be Equal As Strings    ${resp.status_code}   200
       ${DAY1}=  db.get_date_by_timezone  ${tz}
       ${resp}=  Get Queues
       Should Be Equal As Strings  ${resp.status_code}  200
       Set Test Variable  ${qid}  ${resp.json()[0]['id']}
       ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
       Should Be Equal As Strings  ${resp.status_code}  200
       Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
       ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid}  ${DAY1}  ${description}  ${bool[1]}  ${cid}
       Log  ${resp.json()}
       Should Be Equal As Strings  ${resp.status_code}  200
       
       ${wid}=  Get Dictionary Values  ${resp.json()}
       Set Suite Variable  ${wid}  ${wid[0]}       
       ${resp}=  Get Bill By UUId  ${wid}
       Log   ${resp.json()}
       Should Be Equal As Strings  ${resp.status_code}  200    
       ${taxtotal}=  Evaluate  ${amount}/100*${gstper}
       ${due}=  Evaluate  ${amount}+${taxtotal}
       Verify Response  ${resp}  uuid=${wid}  netTotal=${amount}  billStatus=New  billViewStatus=Notshow  netRate=${due}  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=${due}  taxableTotal=${amount}  totalTaxAmount=${taxtotal}
       Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}
       Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1} 
       Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
       Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   ${gstper} 
       Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${amount}
       Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${amount}
  