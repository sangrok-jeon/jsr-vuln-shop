# 12. Information Exposure Security

## 개요
상품 상세 페이지는 `productId` 값을 숫자로 가정하고 바로 파싱한다. 이 과정에서 숫자가 아닌 값을 전달하면 `NumberFormatException`이 발생하고, 취약 버전에서는 별도 예외 처리가 없어 Tomcat 기본 500 오류 페이지가 그대로 노출되었다.

그 결과 사용자는 단순한 입력값 변조만으로도 예외 메시지, 클래스명, 메서드명, 줄번호, 컨테이너 정보를 확인할 수 있었다. 이는 내부 구현 정보 노출로 이어지며, 이후 추가적인 취약점 탐색에 도움이 되는 단서를 제공한다.

## 진입점
- `/jsr/product/detail`
- `/jsr/board/detail`

## 포함 이슈
| 구분 | 취약점 | 설명 |
| --- | --- | --- |
| 주요 취약점 | Information Exposure | 예외 발생 시 내부 클래스, 메서드, 줄번호, 서버 정보가 사용자에게 그대로 노출된다. |
| 관련 이슈 | Improper Input Validation | `productId`, `boardId` 같은 숫자 파라미터 형식을 사전에 검증하지 않아 잘못된 입력이 즉시 예외로 이어진다. |
| 관련 이슈 | Verbose Error Message | 기본 오류 페이지가 상세 예외 메시지와 스택 트레이스를 그대로 보여준다. |

## 취약한 부분
상품 상세 페이지는 `productId`를 바로 `Long.parseLong()`으로 변환하고, 숫자가 아닌 값이 들어오면 `NumberFormatException`이 발생한다. 취약 버전에서는 이 예외를 애플리케이션에서 처리하지 않아 Tomcat 기본 500 오류 페이지가 노출되었다.

이로 인해 공격자는 단순히 `productId=abc`와 같은 비정상 입력만으로도 애플리케이션 내부 구조와 예외 처리 방식을 추정할 수 있다.

## 취약한 코드
파일: `src/main/java/com/jsr/ctf/ProductDetailServlet.java`

```java
long productId = Long.parseLong(request.getParameter("productId"));

ps = conn.prepareStatement("SELECT * FROM JSR_PRODUCTS WHERE PRODUCT_ID=?");
ps.setLong(1, productId);
```

## 취약한 코드 동작 설명
`productId`가 숫자면 정상적으로 상품을 조회하지만, 숫자가 아닌 값이 전달되면 SQL 실행 이전에 `NumberFormatException`이 발생한다. 현재 코드는 `SQLException`만 별도로 처리하고 있어, 숫자 형식 오류는 기본 오류 페이지로 그대로 전파된다.

즉 입력값 검증 부재와 상세 예외 노출이 결합되어, 단순한 비정상 파라미터만으로도 정보노출이 발생한다.

## 취약한 코드 증적자료
1. 정상적인 `productId=1` 요청에서는 상품 상세 페이지가 정상적으로 조회된다.  
   ![01-normal-product-detail](/C:/Users/user/Documents/Playground/ctf-backend-master-clean/docs/images/12-information-exposure-security/01-normal-product-detail.png)

2. `productId=abc`처럼 숫자가 아닌 값을 전달하면 500 오류와 함께 `NumberFormatException`, 클래스명, 줄번호가 그대로 노출된다.  
   ![02-invalid-product-id-error-disclosure](/C:/Users/user/Documents/Playground/ctf-backend-master-clean/docs/images/12-information-exposure-security/02-invalid-product-id-error-disclosure.png)

## 영향
- 내부 클래스명, 메서드명, 줄번호 등 구현 정보가 외부에 노출된다.
- 입력 처리 방식과 예외 흐름이 드러나 추가 취약점 탐색에 도움이 된다.
- 운영 환경에서 불필요한 상세 오류 정보가 사용자에게 그대로 제공된다.

## 대응 방안
- `productId`, `boardId`, `orderId` 같은 숫자 파라미터는 먼저 형식 검증 후 사용한다.
- `NumberFormatException`과 같은 입력값 오류는 애플리케이션에서 직접 처리한다.
- 사용자에게는 일반화된 오류 메시지만 제공하고, 상세 예외 정보는 서버 로그로만 남긴다.
- `web.xml` 또는 전역 예외 처리 방식으로 공통 오류 페이지를 적용한다.

## 수정 코드 예시
파일: `src/main/webapp/WEB-INF/web.xml`

```xml
<error-page>
    <exception-type>java.lang.NumberFormatException</exception-type>
    <location>/WEB-INF/views/error_view.jsp</location>
</error-page>

<error-page>
    <error-code>404</error-code>
    <location>/WEB-INF/views/error_view.jsp</location>
</error-page>

<error-page>
    <error-code>500</error-code>
    <location>/WEB-INF/views/error_view.jsp</location>
</error-page>
```

파일: `src/main/webapp/WEB-INF/views/error_view.jsp`

```jsp
<%
    Throwable ex = (Throwable) request.getAttribute("javax.servlet.error.exception");
    Integer statusCode = (Integer) request.getAttribute("javax.servlet.error.status_code");
    boolean invalidParam = ex instanceof NumberFormatException;
%>
<h1><%= invalidParam ? "유효하지 않은 요청입니다." : "요청을 처리할 수 없습니다." %></h1>
```

## 대응 코드 동작 설명
수정 후에는 숫자 파라미터 오류나 일반적인 404/500 오류가 발생해도 Tomcat 기본 오류 페이지 대신 공통 오류 페이지로 이동한다. 사용자는 더 이상 스택 트레이스나 내부 클래스명을 볼 수 없고, 오류 원인은 일반화된 메시지로만 안내된다.

또한 같은 방식이 `productId`뿐 아니라 `boardId`처럼 다른 숫자 파라미터에도 공통 적용되어, 예외 처리 정책을 일관되게 유지할 수 있다.

## 대응 증적자료
1. `productId=abc` 요청 시 더 이상 500 스택 트레이스가 노출되지 않고, 공통 오류 페이지로 처리된다.  
   ![03-invalid-product-id-handled](/C:/Users/user/Documents/Playground/ctf-backend-master-clean/docs/images/12-information-exposure-security/03-invalid-product-id-handled.png)

2. `boardId=abc` 요청에도 같은 공통 오류 페이지가 적용되어 숫자 파라미터 오류가 일관되게 처리된다.  
   ![04-invalid-board-id-handled](/C:/Users/user/Documents/Playground/ctf-backend-master-clean/docs/images/12-information-exposure-security/04-invalid-board-id-handled.png)
