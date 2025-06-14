name: "[qa] K8S App Deploy"
defaults:
  run:
    shell: bash

env:
  AWS_REGION: us-east-1
  AWS_ACCOUNT_ID: 736790963086
  ENV: qa
  NAMESPACE: gameon
  SSH_PUBLIC_KEY: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDNSDKSBktjoc1s16anJw23ofN10toQZup47+ed5eDsqdUDJ7ljr0r9dxCp8oiI6c4SX6oL0RHK9kHxKlDO7OB9xBNMlSRvXHL4vrCPUYUyMeikPlKFKudvkyP0WaGgeQnZtDeS2WH6QOeT2OpfyC04wYbdc3h1YLOkdyj9EjP02v1NGQhZP0z3XahFGATBXe8hv65olp0fZndqpd1drvBobghfowkYzsen4quhpsl1xBZ8f6MRTBqUYLl20Ml5nG/HZZWyKxYLwxecpwEE6m6K+7KH2S3Vzn+oGbt73IWeOL1YQa24T51I67ALt6+98Xxx2vcJWWEb+VwoTapoSeNGq8HXwHkeY56A00bZ96RlfrcWKN8tonUcY/0H0crG1ahOl4iDoc8bdRWsfTbuEAjOtP+/DFtX0ZaWdk/P3vvwBfnFZ2XmIJpOpPOlyZCpmBK5GOMXYTeW/v00mcU8LV/A1WOyJ2d/bklzqM7BVHDF5KysQP+epmFqcGAp8XXwYjk= dev-gameon"

on:
  push:
    branches:
      - develop
  workflow_dispatch:

jobs:
  fanclash-fcm-pusher:  # Create infrastructure for services on push to Main branch
    name: fanclash-fcm-pusher
    runs-on: ubuntu-latest
    timeout-minutes: 60
    env:
      TAG: "${{ github.sha }}"

    steps:
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID_QA }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY_QA }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Checkout Code
        uses: actions/checkout@v2
        with:
          submodules: true

      - name: Login to ECR
        run: aws ecr get-login-password --region ${{ env.AWS_REGION }} | docker login --username AWS --password-stdin ${{ env.AWS_ACCOUNT_ID }}.dkr.ecr.${{ env.AWS_REGION }}.amazonaws.com

      - name: Build Container
        run: docker build -t ${{ github.job }} .

      - name: Tag Image
        run: docker tag ${{ github.job }}:latest ${{ env.AWS_ACCOUNT_ID }}.dkr.ecr.${{ env.AWS_REGION }}.amazonaws.com/${{ github.job }}:latest

      - name: Push Image
        run: docker push ${{ env.AWS_ACCOUNT_ID }}.dkr.ecr.${{ env.AWS_REGION }}.amazonaws.com/${{ github.job }}:latest

      - name: Logout of Amazon ECR
        if: always()
        run: docker logout ${{ env.AWS_ACCOUNT_ID }}.dkr.ecr.${{ env.AWS_REGION }}.amazonaws.com

      - name: EKS update-kubeconfig
        run: aws eks --region ${{ env.AWS_REGION }} update-kubeconfig --name "${{ env.ENV }}-${{ env.NAMESPACE }}"

      - name: Set KUBE_CONFIG env var
        run: |
          echo "KUBE_CONFIG_DATA<<EOF" >> $GITHUB_ENV
          cat $HOME/.kube/config | base64 >> $GITHUB_ENV
          echo "EOF" >> $GITHUB_ENV
          rm -rf $HOME/.kube/config
 
      - name: EKS Deploy - Deployment
        uses: Consensys/kubernetes-action@master
        env:
          KUBE_CONFIG_DATA: ${{ env.KUBE_CONFIG_DATA }}
        with:
          args: apply -f deploy/eks/deployment_${{ env.ENV }}.yaml --namespace=${{ env.ENV }}
