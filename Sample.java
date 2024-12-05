import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.powermock.api.mockito.PowerMockito;
import org.powermock.modules.junit5.PowerMockExtension;

import static org.mockito.Mockito.*;

@ExtendWith(PowerMockExtension.class) // PowerMockExtension for JUnit 5
public class PowerMockitoTest { // test

    @Test
    void testMockStaticMethod() {
        // Mock the static method
        PowerMockito.mockStatic(MyStaticClass.class);
        PowerMockito.when(MyStaticClass.getMessage()).thenReturn("Mocked Message");

        // Verify the mocked behavior
        String result = MyStaticClass.getMessage();
        assert(result.equals("Mocked Message"));
    }
}
