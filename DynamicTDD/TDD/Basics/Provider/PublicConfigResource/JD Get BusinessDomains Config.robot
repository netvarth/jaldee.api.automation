*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Customer
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Test Cases ***

JD-TC-GetBusinessDomains -1
       [Documentation]   Provider check to get business domain configurations
       ${resp}=   Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=   Get BusinessDomainsConf
       Should Be Equal As Strings   ${resp.status_code}   200
       Should Be Equal As Strings  ${resp.json()[0]['domain']}  healthCare
       Should Be Equal As Strings  ${resp.json()[0]['subDomains'][0]['subDomain']}  physiciansSurgeons
       Should Be Equal As Strings  ${resp.json()[0]['subDomains'][1]['subDomain']}  dentists
       Should Be Equal As Strings  ${resp.json()[0]['subDomains'][2]['subDomain']}  alternateMedicinePractitioners
       Should Be Equal As Strings  ${resp.json()[1]['domain']}  personalCare
       Should Be Equal As Strings  ${resp.json()[1]['subDomains'][0]['subDomain']}  beautyCare
       Should Be Equal As Strings  ${resp.json()[2]['domain']}  foodJoints
       Should Be Equal As Strings  ${resp.json()[2]['subDomains'][0]['subDomain']}  restaurants
       Should Be Equal As Strings  ${resp.json()[3]['domain']}  professionalConsulting
       Should Be Equal As Strings  ${resp.json()[3]['subDomains'][0]['subDomain']}  lawyers
       Should Be Equal As Strings  ${resp.json()[3]['subDomains'][1]['subDomain']}  charteredAccountants
       Should Be Equal As Strings  ${resp.json()[3]['subDomains'][2]['subDomain']}  taxConsultants
       Should Be Equal As Strings  ${resp.json()[3]['subDomains'][3]['subDomain']}  civilArchitects 
       Should Be Equal As Strings  ${resp.json()[4]['domain']}  vastuAstrology
       Should Be Equal As Strings  ${resp.json()[4]['subDomains'][0]['subDomain']}  vastu
       Should Be Equal As Strings  ${resp.json()[5]['domain']}  religiousPriests
       Should Be Equal As Strings  ${resp.json()[5]['subDomains'][0]['subDomain']}  temple
       Should Be Equal As Strings  ${resp.json()[5]['subDomains'][1]['subDomain']}  poojari
       Should Be Equal As Strings  ${resp.json()[6]['domain']}  finance
       Should Be Equal As Strings  ${resp.json()[6]['subDomains'][0]['subDomain']}  bank
       Should Be Equal As Strings  ${resp.json()[6]['subDomains'][1]['subDomain']}  nbfc
       Should Be Equal As Strings  ${resp.json()[6]['subDomains'][2]['subDomain']}  insurance
       Should Be Equal As Strings  ${resp.json()[7]['domain']}  veterinaryPetcare
       Should Be Equal As Strings  ${resp.json()[7]['subDomains'][0]['subDomain']}  veterinarydoctor
       Should Be Equal As Strings  ${resp.json()[7]['subDomains'][1]['subDomain']}  petcare

       
JD-TC-GetBusinessDomains -UH1
       [Documentation]   Provider check to get business domain configurations without login
       ${resp}=   Get BusinessDomainsConf
       Should Be Equal As Strings   ${resp.status_code}   200
       
JD-TC-GetBusinessDomains -UH2
       [Documentation]    Consumer check to get business domain configurations
       ${resp}=   Consumer Login  ${CUSERNAME0}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=   Get BusinessDomainsConf
       Should Be Equal As Strings   ${resp.status_code}   200