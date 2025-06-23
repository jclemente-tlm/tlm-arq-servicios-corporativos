styles {

    # MARK: :base:styles
    #  ______
    # |   __ \.---.-.-----.-----.
    # |   __ <|  _  |__ --|  -__|
    # |______/|___._|_____|_____|
    #
    element "Element" {
        width 600
        shape RoundedBox
        fontSize 30
    }

    element "Software System" {
        shape RoundedBox
        background #DAE8FC
        stroke #6C8EBF
        color #1A1A1A
    }

    element "Container" {
        background #E1D5E7
        stroke #9673A6
        color #1A1A1A
    }

    element "Component" {
        background #FFF2CC
        stroke #D6B656
        color #1A1A1A
    }

    element "Deployment Node" {
        strokeWidth 1
        metadata true
    }

    element "Person" {
        shape Person
        background #D5E8D4
        stroke #82B366
        color #1A1A1A
        width 300
        description false
    }

    element "External" {
        background #EEEEEE
        stroke #999999
        color #1A1A1A
    }

    element "Store" {
        background #FAD9D5
        stroke #AE4132
        color #1A1A1A
    }

    element "Future" {
        background #8CD0F0
        color #000000
    }

    element "Group" {
        strokeWidth 2
        fontSize 34
    }

    element "Boundary" {
        strokeWidth 2
        fontSize 34
    }

    # MARK: :App:styles
    element "Web App" {
        shape WebBrowser
    }

    element "Desktop App" {
        shape Window
    }

    element "Mobile App" {
        shape MobileDeviceLandscape
    }

    element "Database" {
        shape Cylinder
    }

    element "File Storage" {
        shape Folder
    }

    element "Message Bus" {
        shape Pipe
    }

    # MARK: :Notification:styles
    element "Email" {
        icon ../icons/notifications/email.png
    }

    element "SMS" {
        icon ../icons/notifications/sms.png
    }

    element "WhatsApp" {
        icon ../icons/notifications/whatsapp.png
    }

    element "Push" {
        icon ../icons/notifications/push-notification.png
    }

    # MARK: :Country:styles
    element "Peru" {
        icon ../icons/flags/flag-peru.png
    }
    element "Ecuador" {
        icon ../icons/flags/flag-ecuador.png
    }
    element "Colombia" {
        icon ../icons/flags/flag-colombia.png
    }
    element "Mexico" {
        icon ../icons/flags/flag-mexico.png
    }

    # MARK: :Technology:styles
    element "AWS" {
        icon ../icons/cloud/aws.png
    }
    element "AWS S3" {
        icon ../icons/cloud/aws-s3.png
    }
    element "Docker"{
        icon ../icons/infrastructure/docker.png
    }
    element "Oracle"{
        icon ../icons/databases/oracle.png
    }
    element "PostgreSQL"{
        icon ../icons/databases/postgresql.png
    }
    element "DynamoDB"{
        icon ../icons/databases/aws-dynamodb.png
    }
    element "SQL Server"{
        icon ../icons/databases/sql-server.png
    }
    element "CSharp"{
        icon ../icons/languages/csharp.png
    }
    element "Python"{
        icon ../icons/languages/python.png
    }
    element "React"{
        icon ../icons/frameworks/react.png
    }
    element "RabbitMQ"{
        icon ../icons/messaging/rabbitmq.png
    }
    element "Redis"{
        icon ../icons/databases/redis.png
    }
    element "Kafka"{
        icon ../icons/messaging/kafka.png
    }
    element "Kafka Connect"{
        icon ../icons/infrastructure/kafka-connect.png
    }
    element "Kafka UI"{
        icon ../icons/infrastructure/kafka-ui.png
    }
    element "Grafana"{
        icon ../icons/tools/grafana.png
    }
    element "Prometheus"{
        icon ../icons/tools/prometheus.png
    }
    element "Keycloak"{
        icon ../icons/security/keycloak.png
    }

    # MARK: :TrackAndTrace:styles
    element "TrackAndTrace" {
        background #D0F5A9
        stroke #82B366
        color #1A1A1A
    }

    element "Metadata Off" {
        metadata false
    }
    element "Failover" {
        opacity 25
    }

    element "Amazon Web Services" {
        icon ../icons/cloud/aws.png
    }

    # MARK: :relationship:styles
    #  ______         __         __   __                     __     __
    # |   __ \.-----.|  |.---.-.|  |_|__|.-----.-----.-----.|  |--.|__|.-----.
    # |      <|  -__||  ||  _  ||   _|  ||  _  |     |__ --||     ||  ||  _  |
    # |___|__||_____||__||___._||____|__||_____|__|__|_____||__|__||__||   __|
    #                                                                  |__|
    relationship "Relationship" {
        style "solid"
        thickness 2
    }

}
