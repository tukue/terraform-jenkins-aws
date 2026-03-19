# Platform Engineering Checklists

## Pre-Deployment Checklist

### Infrastructure Review
- [ ] Terraform validates without errors
- [ ] All variables defined and documented
- [ ] Security groups follow least privilege
- [ ] Encryption enabled for data at rest
- [ ] Backup strategy documented
- [ ] Disaster recovery plan in place
- [ ] Cost estimation reviewed
- [ ] Capacity planning complete

### Code Quality
- [ ] Code formatted with `terraform fmt`
- [ ] Linting passes with `tflint`
- [ ] Security scanning passes with `checkov`
- [ ] No hardcoded secrets or credentials
- [ ] Documentation complete and accurate
- [ ] Examples provided for module usage
- [ ] Comments explain complex logic

### Testing
- [ ] Manual testing in dev environment
- [ ] All edge cases tested
- [ ] Error handling verified
- [ ] Rollback procedure tested
- [ ] Performance benchmarked
- [ ] Load testing completed (if applicable)

### Compliance
- [ ] Meets platform standards
- [ ] Follows naming conventions
- [ ] Required tags applied
- [ ] Security policies followed
- [ ] Compliance requirements met
- [ ] Audit logging configured

### Team Readiness
- [ ] Team trained on new infrastructure
- [ ] Runbooks prepared
- [ ] On-call rotation updated
- [ ] Documentation published
- [ ] Stakeholders notified
- [ ] Change window scheduled

## Deployment Checklist

### Pre-Deployment
- [ ] Maintenance window scheduled
- [ ] Backup created
- [ ] Team members standing by
- [ ] Rollback plan documented
- [ ] Monitoring dashboards prepared
- [ ] Communication channel open (#incidents)

### During Deployment
- [ ] Changes applied incrementally
- [ ] Each step verified
- [ ] Metrics monitored
- [ ] Issues logged
- [ ] Team notified of progress
- [ ] Health checks passing

### Post-Deployment
- [ ] All systems operational
- [ ] Metrics collected and analyzed
- [ ] Documentation updated
- [ ] Alerts configured
- [ ] Training completed
- [ ] Success criteria met

## Production Readiness Checklist

### Security
- [ ] Authentication enabled
- [ ] Authorization configured
- [ ] All APIs secured
- [ ] SSL/TLS enabled
- [ ] Secrets managed properly
- [ ] Regular security audits scheduled
- [ ] Vulnerability scanning enabled

### Reliability
- [ ] No single points of failure
- [ ] Automatic failover configured
- [ ] Multi-AZ deployment (prod)
- [ ] Backup and restore tested
- [ ] Capacity properly sized
- [ ] Auto-scaling configured
- [ ] Health checks active

### Observability
- [ ] Metrics collection enabled
- [ ] Logs being collected
- [ ] Dashboards created
- [ ] Alerts configured
- [ ] Alert routing working
- [ ] SLOs defined
- [ ] Trendy analysis setup

### Operations
- [ ] Runbooks documented
- [ ] On-call procedures established
- [ ] Escalation paths clear
- [ ] Team trained on procedures
- [ ] Incident response plan ready
- [ ] Communication channels ready

### Documentation
- [ ] Getting started guide complete
- [ ] Architecture documented
- [ ] API documentation complete
- [ ] Runbooks written
- [ ] Troubleshooting guide available
- [ ] FAQ created
- [ ] Knowledge base updated

## Regular Maintenance Checklist

### Monthly
- [ ] Review and analyze costs
- [ ] Check security updates available
- [ ] Review monitoring alerts (for noise)
- [ ] Update documentation as needed
- [ ] Team sync on infrastructure status
- [ ] Backup restoration test

### Quarterly
- [ ] Disaster recovery drill
- [ ] Security audit
- [ ] Performance review
- [ ] Capacity planning review
- [ ] Dependencies update check
- [ ] Team training refresher

### Annually
- [ ] Comprehensive security audit
- [ ] Architecture review and update
- [ ] Cost optimization review
- [ ] Compliance verification
- [ ] Technology stack evaluation
- [ ] Roadmap planning

## Incident Response Checklist

### Detection
- [ ] Alert triggered
- [ ] Severity assessed
- [ ] On-call notified
- [ ] Incident created in tracking system

### Response
- [ ] Team assembled
- [ ] Communication channel opened
- [ ] Severity and impact assessed
- [ ] Initial mitigation steps identified
- [ ] Root cause investigation started
- [ ] Stakeholders updated

### Resolution
- [ ] Root cause identified
- [ ] Fix implemented and tested
- [ ] Changes deployed
- [ ] System stability verified
- [ ] Affected services recovered
- [ ] Metrics return to normal

### Post-Incident
- [ ] Incident log completed
- [ ] Timeline documented
- [ ] Root cause analysis done
- [ ] Preventive measures identified
- [ ] Updates to runbooks made
- [ ] Team debriefing scheduled
- [ ] Action items tracked

## Change Management Checklist

### Planning
- [ ] Change request created
- [ ] Impact analysis completed
- [ ] Risk assessment done
- [ ] Change window scheduled
- [ ] Approval obtained
- [ ] Stakeholders notified

### Preparation
- [ ] Terraform changes reviewed
- [ ] Tests passed
- [ ] Rollback plan created
- [ ] Documentation updated
- [ ] Team trained
- [ ] Communication plan set

### Execution
- [ ] Change window confirmed
- [ ] Team ready and available
- [ ] Status updates sent regularly
- [ ] Rollback readily available
- [ ] Monitoring active

### Verification
- [ ] All changes deployed successfully
- [ ] Health checks passing
- [ ] Metrics normal
- [ ] Tests passing
- [ ] Users report success
- [ ] Performance acceptable

### Documentation
- [ ] Change log updated
- [ ] Documentation files updated
- [ ] Lessons learned captured
- [ ] Team feedback collected
- [ ] Process improvements identified
