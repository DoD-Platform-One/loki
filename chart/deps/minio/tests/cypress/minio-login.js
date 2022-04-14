describe('Minio Login', function() {
  it('Check Minio Login', function() {
      cy.visit(Cypress.env('url'), { timeout: 15000 })
      // Fill the username
      cy.get('input[id="accessKey"]').type(Cypress.env('accesskey'),{delay: 0})

      // Fill the password
      cy.get('input[id="secretKey"]').type(Cypress.env('secretkey'),{delay: 0})

      // Locate and submit the form
      cy.get('form').submit();

      // Verify the app redirected you to the homepage
      cy.location('pathname', { timeout: 60000 }).should('eq', '/buckets');
      
      // Verify the page title is "Home"
      cy.title().should('eq', 'MinIO Console');
    
  })
})
