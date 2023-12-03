NS=test

kubectl create namespace $NS --dry-run=client -o yaml | kubectl apply -f - 2>&1 | \
    grep -v "kubectl.kubernetes.io/last-applied-configuration"
kubectl label namespace $NS --overwrite \
    pod-security.kubernetes.io/enforce=privileged \
    pod-security.kubernetes.io/audit=privileged \
    pod-security.kubernetes.io/warn=privileged \
    security.openshift.io/scc.podSecurityLabelSync=false
until [[ $(kubectl get sa default -n $NS -o=jsonpath='{.metadata.creationTimestamp}') ]]; do \
    echo "waiting for service account for $NS namespace to exist..."; sleep 3; done

# If oc scc resource exists, configure role that allows $NS to have priviledged access
ocbin=$(which oc 2>/dev/null)
[ -x "$ocbin" ] && scc=$($ocbin api-resources | grep securitycontextconstraints)
if [ -n "$scc" ] ; then
    $ocbin get rolebinding $NS --no-headers -n $NS 2>/dev/null || \
    { $ocbin create role $NS --verb=use --resource=scc --resource-name=privileged -n $NS ;
      $ocbin create rolebinding $NS --role=${NS} --group=system:serviceaccounts:${NS} -n $NS ; }
fi

