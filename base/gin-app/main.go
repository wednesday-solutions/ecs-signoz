package main

import (
	"context"
	"time"

	"log"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
	_ "github.com/mattn/go-sqlite3"
	"github.com/uptrace/opentelemetry-go-extra/otelsql"
	"go.opentelemetry.io/contrib/instrumentation/github.com/gin-gonic/gin/otelgin"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	semconv "go.opentelemetry.io/otel/semconv/v1.4.0"
	"google.golang.org/grpc/credentials"
)

var (
	serviceName  = os.Getenv("SERVICE_NAME")
	collectorURL = os.Getenv("OTEL_EXPORTER_OTLP_ENDPOINT")
	insecure     = os.Getenv("INSECURE_MODE")
)

func initTracer() func(context.Context) error {

	secureOption := otlptracegrpc.WithTLSCredentials(credentials.NewClientTLSFromCert(nil, ""))
	if len(insecure) > 0 {
		secureOption = otlptracegrpc.WithInsecure()
	}

	exporter, err := otlptrace.New(
		context.Background(),
		otlptracegrpc.NewClient(
			secureOption,
			otlptracegrpc.WithEndpoint(collectorURL),
		),
	)

	if err != nil {
		log.Fatal(err)
	}
	resources, err := resource.New(
		context.Background(),
		resource.WithAttributes(
			attribute.String("service.name", serviceName),
			attribute.String("library.language", "go"),
		),
	)
	if err != nil {
		log.Printf("Could not set resources: ", err)
	}

	otel.SetTracerProvider(
		sdktrace.NewTracerProvider(
			sdktrace.WithSampler(sdktrace.AlwaysSample()),
			sdktrace.WithBatcher(exporter),
			sdktrace.WithResource(resources),
		),
	)
	return exporter.Shutdown
}

func main() {

	cleanup := initTracer()
	defer cleanup(context.Background())

	r := gin.Default()
	r.Use(otelgin.Middleware(serviceName))
	db, err := otelsql.Open("sqlite3", "file::memory:?cache=shared",
		otelsql.WithAttributes(semconv.DBSystemSqlite),
		otelsql.WithDBName("mydb"))

	if err != nil {
		panic(err)
	}

	_, err = db.Exec(`CREATE TABLE Persons (
		PersonID INTEGER PRIMARY KEY AUTOINCREMENT,
	
		FirstName varchar(255),
	
	);`)
	if err != nil {
		log.Println(err)
	} else {
		log.Println("created persons tables")
	}
	r.GET("/ping", func(c *gin.Context) {
		time.Sleep(2 * time.Second)

		c.Status(200)
		c.JSON(http.StatusOK, gin.H{"hello": "World"})

	})

	r.GET("/ping/add", func(ctx *gin.Context) {
		_, err := db.ExecContext(ctx.Request.Context(), "INSERT INTO Persons (FirstName) values ($1)", "john smith")
		if err != nil {
			log.Println(err)
		} else {
			log.Println("added a persons")
		}
		ctx.Status(200)
		ctx.JSON(http.StatusOK, gin.H{"hello": "World"})
	})

	r.Run(":8090")

}
