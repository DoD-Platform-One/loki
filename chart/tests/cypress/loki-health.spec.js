beforeEach(function () {
    cy.getCookies().then(cookies => {
      const namesOfCookies = cookies.map(cm => cm.name)
      Cypress.Cookies.preserveOnce(...namesOfCookies)
    })
  })
  
  describe('Loki Test', function() {
    Cypress.on('uncaught:exception', (err, runnable) => {
      return false
    })
  
    if (Cypress.env("check_datasource")) {
  
        it('Check Loki is available as a data source in grafana and connected', function() {
            cy.visit(Cypress.env('grafana_url'))
            cy.get('input[name="user"]')
              .type('admin')
            cy.get('input[name="password"]')
              .type('prom-operator')
            cy.contains("Log in").click()
            cy.get('.page-toolbar').contains('General', {timeout: 30000})
            // Visit the datasources page
            cy.visit(`${Cypress.env('grafana_url')}/datasources`)
  
            // // // Enter 'loki' in the search field and 
            cy.get('.css-yn255a-input-input')
            .type('loki')
            // Click on the loki datasource
            cy.get('.css-1cqw476').contains('Loki')
            cy.get('.css-1cqw476').click()
            // Click on the 'Save & test` button
            cy.get('.css-1sara2j-button > .css-1mhnkuh').click()
            // Check to ensure the data source is working
            cy.get('.p-t-2').contains('Data source connected and labels found', {timeout: 10000})
          })
  
          after(function () {
            cy.clearCookies()
          })
    }
  })