import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.JsonDeserializer;

import java.io.IOException;
import java.math.BigDecimal;

public class StrictBigDecimalDeserializer extends JsonDeserializer<BigDecimal> {

    @Override
    public BigDecimal deserialize(JsonParser p, DeserializationContext ctxt)
            throws IOException, JsonProcessingException {
        String value = p.getText();
        if (value.contains("e") || value.contains("E")) {
            throw new IOException("Exponential notation is not allowed for decimal values.");
        }
        try {
            return new BigDecimal(value);
        } catch (NumberFormatException ex) {
            throw new IOException("Invalid decimal format.", ex);
        }
    }
}
import com.fasterxml.jackson.databind.Module;
import com.fasterxml.jackson.databind.module.SimpleModule;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import java.math.BigDecimal;

@Configuration
public class JacksonConfig {

    @Bean
    public Module strictBigDecimalModule() {
        SimpleModule module = new SimpleModule();
        module.addDeserializer(BigDecimal.class, new StrictBigDecimalDeserializer());
        return 


mapper.enable(JsonParser.Feature.ALLOW_NON_NUMERIC_NUMBERS);
        mapper.enable(JsonParser.Feature.USE_BIG_DECIMAL_FOR_FLOATS)




